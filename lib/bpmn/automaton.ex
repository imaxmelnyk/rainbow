defmodule Bpmn.Automaton do
  use TypedStruct
  typedstruct do
    field :states, [%{}], default: []
    field :transitions, [{%{}, %{}, (%{} -> boolean)}], default: []
  end

  alias Bpmn.Process
  alias Bpmn.Element
  alias Bpmn.Element.SequenceFlow
  alias Bpmn.Element.Event
  alias Bpmn.Element.Gateway

  @spec build_from_process(Process.t) :: __MODULE__.t
  def build_from_process(process) do
    flows =
      Enum.filter(process.elements, &SequenceFlow.is_sequence_flow/1)
    start_events =
      Enum.filter(process.elements, &Event.Start.is_start_event/1)
    start_flows =
      Enum.filter(flows, fn flow -> flow.source in Enum.map(start_events, &(&1.id)) end)
    start_states =
      Enum.map(start_flows, fn start_flow ->
        Enum.reduce(flows, %{}, fn flow, state ->
          cond do
            flow.id == start_flow.id -> Map.put(state, flow.id, true)
            true -> Map.put(state, flow.id, false)
          end
        end)
      end)

    automaton =
      Enum.reduce(start_states, %__MODULE__{}, fn state, automaton -> expand(process, state, automaton) end)
    remove_taos(process, automaton)
  end

  @spec expand(Process.t, %{}, __MODULE__.t) :: __MODULE__.t
  def expand(process, state, automaton) do
    cond do
      has_state(automaton, state) -> automaton
      is_final_state(process, state) -> automaton
      true ->
        automaton = add_state(automaton, state)

        state_to_growed_flows(process, state)
        |> Enum.group_by((fn {_, _, target} -> target end), (fn {flow, _, _} -> flow end))
        |> Enum.reduce(automaton, fn {target, flows}, automaton ->
          cond do
            Gateway.Parallel.is_parallel_gateway(target) ->
              num_flows_with_target =
                process.elements
                |> Enum.filter(fn elem -> SequenceFlow.is_sequence_flow(elem) && elem.target == target.id end)
                |> Enum.count()
              actual_num_flows_with_target =
                Enum.count(flows)

              cond do
                num_flows_with_target == actual_num_flows_with_target ->
                  new_state =
                    Enum.reduce(flows, state, fn flow, state -> Map.put(state, flow.id, false) end)
                  new_state =
                    process.elements
                    |> Enum.filter(fn elem -> SequenceFlow.is_sequence_flow(elem) && elem.source == target.id end)
                    |> Enum.reduce(new_state, fn new_flow, new_state -> Map.put(new_state, new_flow.id, true) end)
                  new_automaton =
                    add_transition(automaton, {state, new_state, &SequenceFlow.is_allowed/1})

                  expand(process, new_state, new_automaton)
                true ->
                  automaton
              end
            true ->
              Enum.reduce(flows, automaton, fn flow, automaton ->
                process.elements
                |> Enum.filter(fn elem -> SequenceFlow.is_sequence_flow(elem) && elem.source == target.id end)
                |> Enum.reduce(automaton, fn new_flow, automaton ->
                  new_state = state |> Map.put(flow.id, false) |> Map.put(new_flow.id, true)
                  new_automaton = automaton |> add_transition({state, new_state, new_flow.is_allowed})

                  expand(process, new_state, new_automaton)
                end)
              end)
          end
        end)
    end
  end

  @spec remove_taos(Process.t, __MODULE__.t) :: __MODULE__.t
  defp remove_taos(process, automaton) do
    {automaton, removed_states} =
      remove_taos(process, automaton, [])

    new_states =
      automaton.states -- removed_states
    new_transitions =
      Enum.filter(automaton.transitions, fn {from, to, _} ->
        from not in removed_states && to not in removed_states
      end)

    %{automaton | states: new_states, transitions: new_transitions}
  end

  @spec remove_taos(Process.t, __MODULE__.t, list(%{})) :: {__MODULE__.t, list(%{})}
  defp remove_taos(process, automaton, removed_states) do
    automaton.transitions
    |> Enum.reduce_while({automaton, removed_states}, fn {from, to, is_allowed}, {automaton, removed_states} ->
      from_flows =
        state_to_growed_flows(process, from)
      to_flows =
        state_to_growed_flows(process, to)

      from_targets =
        from_flows
        |> Enum.map(fn {_, _, target} -> target end)
        |> Enum.uniq()
      to_sources =
        to_flows
        |> Enum.map(fn {_, source, _} -> source end)
        |> Enum.uniq()

      case {from_targets, to_sources} do
        {[elem], [elem]} ->
          cond do
            Gateway.is_gateway(elem) ->
              IO.inspect(elem)
              new_state = merge_states(from, to)
              automaton =
                automaton
                |> add_state(new_state)
                |> remove_transition({from, to, is_allowed})

              transitions =
                cond do
                  Gateway.Parallel.is_parallel_gateway(elem) ->
                    Enum.map(automaton.transitions, fn {f, t, is_a} ->
                      cond do
                        f == to -> {new_state, t, is_a}
                        t == from -> {f, new_state, is_a}
                        true -> {f, t, is_a}
                      end
                    end)
                  Gateway.Exclusive.is_exclusive_gateway(elem) ->
                    Enum.reduce(automaton.transitions, automaton.transitions, fn {f, t, is_a}, transitions ->
                      cond do
                        f == to -> [{new_state, t, (fn vars -> is_a.(vars) && is_allowed.(vars) end)} | transitions]
                        t == from -> [{f, new_state, (fn vars -> is_a.(vars) && is_allowed.(vars) end)} | transitions]
                        true -> transitions
                      end
                    end)
                end

              new_automaton = %{automaton | transitions: transitions}
              new_removed_states = removed_states ++ [from, to]

              {:halt, remove_taos(process, new_automaton, new_removed_states)}
            true -> {:cont, {automaton, removed_states}}
          end
        _ -> {:cont, {automaton, removed_states}}
      end
    end)
  end

  @spec state_to_growed_flows(__MODULE__.t, %{}) :: {SequenceFlow.t, Element.source_element, Element.target_element}
  defp state_to_growed_flows(process, state) do
    state
    |> Enum.filter(fn {_, has_token} -> has_token end)
    |> Enum.map(fn {flow_id, _} ->
      with {:ok, flow} <- Element.find_by_id(process.elements, flow_id),
           {:ok, source} <- Element.find_by_id(process.elements, flow.source),
           {:ok, target} <- Element.find_by_id(process.elements, flow.target) do
        {flow, source, target}
      else
        _error -> raise "Something went wrong..."
      end
    end)
  end

  @spec has_state(__MODULE__.t, %{}) :: boolean
  defp has_state(automaton, state), do: Enum.member?(automaton.states, state)

  @spec add_state(__MODULE__.t, %{}) :: __MODULE__.t
  defp add_state(automaton, state), do: %{automaton | states: [state | automaton.states]}

  @spec remove_state(__MODULE__.t, %{}) :: __MODULE__.t
  defp remove_state(automaton, state), do: %{automaton | states: Enum.filter(automaton.states, &(&1 != state))}

  @spec add_transition(__MODULE__.t, {%{}, %{}, (%{} -> boolean)}) :: __MODULE__.t
  defp add_transition(automaton, transition), do: %{automaton | transitions: [transition | automaton.transitions]}

  @spec remove_transition(__MODULE__.t, {%{}, %{}, (%{} -> boolean)}) :: __MODULE__.t
  defp remove_transition(automaton, {dfrom, dto, _}) do
    new_transitions =
      Enum.filter(automaton.transitions, fn {from, to, _} -> !(dfrom == from && dto == to) end)

    %{automaton | transitions: new_transitions}
  end

  @spec is_final_state(__MODULE__.t, %{}) :: boolean
  defp is_final_state(process, state) do
    Enum.reduce_while(state, true, fn {flow_id, has_token}, _ ->
      cond do
        !has_token -> {:cont, true}
        true ->
          with {:ok, flow} <- Element.find_by_id(process.elements, flow_id),
               {:ok, target} <- Element.find_by_id(process.elements, flow.target) do
            if Event.End.is_end_event(target), do: {:cont, true}, else: {:halt, false}
          else
            _ -> raise "Something went wrong..."
          end
      end
    end)
  end

  defp merge_states(state1, state2) do
    Enum.map(state1, fn {flow_id, has_token} ->
      {flow_id, has_token || Map.get(state2, flow_id, false)}
    end)
  end
end
