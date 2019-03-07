defmodule Bpmn.Event.End do
  @enforce_keys [:id]
  defstruct [:id, :name]

  @type t :: %__MODULE__{id: integer, name: String.t()}

  def is_end_event(%__MODULE__{}), do: true
  def is_end_event(_), do: false
end
