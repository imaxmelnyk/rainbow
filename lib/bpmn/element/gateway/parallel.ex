defmodule Bpmn.Element.Gateway.Parallel do
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
  end

  def is_parallel_gateway(%__MODULE__{}), do: true
  def is_parallel_gateway(_), do: false
end