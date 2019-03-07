defmodule Bpmn.SequenceFlow do
  alias Bpmn.Element

  @enforce_keys [:id, :from, :to]
  defstruct [:id, :name, :from, :to]

  @type t :: %__MODULE__{
          id: integer,
          name: String.t(),
          from: Element.t_source(),
          to: Element.t_target()
        }

  def is_sequence_flow(%__MODULE__{}), do: true
  def is_sequence_flow(_), do: false
end
