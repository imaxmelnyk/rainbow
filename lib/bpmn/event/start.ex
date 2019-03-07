defmodule Bpmn.Event.Start do
  @enforce_keys [:id]
  defstruct [:id, :name]

  @type t :: %__MODULE__{id: integer, name: String.t()}

  def is_start_event(%__MODULE__{}), do: true
  def is_start_event(_), do: false
end
