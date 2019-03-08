defmodule Bpmn.Element.SequenceFlow do
  alias Bpmn.Element
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
    field :from, Element.source_element() | integer(), enforce: true
    field :to, Element.target_element() | integer(), enforce: true
  end

  @spec is_sequence_flow(any()) :: boolean()
  def is_sequence_flow(%__MODULE__{}), do: true
  def is_sequence_flow(_), do: false

  @spec decode(map()) :: {:ok, __MODULE__.t()} | :error
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> :error
    end
  end

  @spec grow_from([Element.t()], __MODULE__.t()) :: {:ok, __MODULE__.t()} | :error
  defp grow_from(elements, sequence_flow) do
    cond do
      Element.is_source_element(sequence_flow.from) -> {:ok, sequence_flow}
      is_integer(sequence_flow.from) ->
        case Element.find_by_id(elements, sequence_flow.from) do
          {:ok, from} ->
            cond do
              Element.is_source_element(from) -> {:ok, struct(sequence_flow, from: from)}
              true -> :error
            end
          _ -> :error
        end
      true -> :error
    end
  end

  @spec grow_to([Element.t()], __MODULE__.t()) :: {:ok, __MODULE__.t()} | :error
  defp grow_to(elements, sequence_flow) do
    cond do
      Element.is_target_element(sequence_flow.to) -> {:ok, sequence_flow}
      is_integer(sequence_flow.to) ->
        case Element.find_by_id(elements, sequence_flow.to) do
          {:ok, to} ->
            cond do
              Element.is_target_element(to) -> {:ok, struct(sequence_flow, to: to)}
              true -> :error
            end
          _ -> :error
        end
      true -> :error
    end
  end

  @spec grow([Element.t()], __MODULE__.t()) :: {:ok, __MODULE__.t()} | :error
  def grow(elements, sequence_flow) do
    case grow_from(elements, sequence_flow) do
      {:ok, sequence_flow} -> grow_to(elements, sequence_flow)
      _ -> :error
    end
  end
end
