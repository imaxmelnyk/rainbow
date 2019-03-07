defmodule Bpmn.Activity.Manual do
  @enforce_keys [:id]
  defstruct [:id, :name]

  @type t :: %__MODULE__{id: integer, name: String.t()}

  def is_manual_actuvity(%__MODULE__{}), do: true
  def is_manual_actuvity(_), do: false
end
