defmodule Bpmn.Gateway.Exclusive do
  @enforce_keys [:id]
  defstruct [:id, :name]

  @type t :: %__MODULE__{id: integer, name: String.t()}

  def is_exclusive_gateway(%__MODULE__{}), do: true
  def is_exclusive_gateway(_), do: false
end
