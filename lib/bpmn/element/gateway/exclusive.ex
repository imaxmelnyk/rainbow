defmodule Bpmn.Element.Gateway.Exclusive do
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
  end

  @spec is_exclusive_gateway(any()) :: boolean()
  def is_exclusive_gateway(%__MODULE__{}), do: true
  def is_exclusive_gateway(_), do: false
end
