defmodule Bpmn.Element.Variable do
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
    field :value, String.t() | float() | boolean()
  end

  @spec is_variable(any()) :: boolean()
  def is_variable(%__MODULE__{}), do: true
  def is_variable(_), do: false
end
