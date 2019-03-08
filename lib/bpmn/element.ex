defmodule Bpmn.Element do
  alias Bpmn.Element.{Event, Activity, Gateway, SequenceFlow, Variable}

  @type any_element() :: Event.t() | Activity.t() | Gateway.t() | SequenceFlow.t() | Variable.t()
  @type source_element() :: Event.Start.t() | Activity.t() | Gateway.t()
  @type target_element() :: Event.End.t() | Activity.t() | Gateway.t()

  @spec is_element(any()) :: boolean()
  def is_element(v) do
    Event.is_event(v) ||
      Activity.is_activity(v) ||
      Gateway.is_gateway(v) ||
      SequenceFlow.is_sequence_flow(v) ||
      Variable.is_variable(v)
  end

  @spec is_source_element(any()) :: boolean()
  def is_source_element(v) do
    Event.Start.is_start_event(v) ||
      Activity.is_activity(v) ||
      Gateway.is_gateway(v)
  end

  @spec is_target_element(any()) :: boolean()
  def is_target_element(v) do
    Event.End.is_end_event(v) ||
      Activity.is_activity(v) ||
      Gateway.is_gateway(v)
  end

  @spec decode(map()) :: {:ok, __MODULE__.t()} | :error
  def decode(json) do
    case Map.pop(json, :type) do
      {"activity", json} -> Activity.decode(json)
      {"event", json} -> Event.decode(json)
      {"gateway", json} -> Gateway.decode(json)
      {"sequence-flow", json} -> SequenceFlow.decode(json)
      {"variable", json} -> Variable.decode(json)
      _ -> :error
    end
  end

  @spec grow([Element.t()], __MODULE__.t()) :: {:ok, __MODULE__.t()} | :error
  def grow(elements, elem) do
    cond do
      SequenceFlow.is_sequence_flow(elem) -> SequenceFlow.grow(elements, elem)
      true -> {:ok, elem}
    end
  end

  @spec find_by_id([Element.t()], integer()) :: {:ok, __MODULE__.t()} | :error
  def find_by_id(elements, id) do
    case Enum.find(elements, fn elem -> elem.id == id end) do
      nil -> :error
      elem -> {:ok, elem}
    end
  end
end
