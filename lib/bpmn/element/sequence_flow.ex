defmodule Bpmn.Element.SequenceFlow do
  alias Bpmn.Element
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
    field :from, Element.source_element(), enforce: true
    field :to, Element.target_element(), enforce: true
  end

  @spec is_sequence_flow(any()) :: boolean()
  def is_sequence_flow(%__MODULE__{}), do: true
  def is_sequence_flow(_), do: false
end
