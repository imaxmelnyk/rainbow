defmodule Bpmn.Process do
  alias Bpmn.Element
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
    field :elements, [Element.any_element()], enforce: true
  end

  def is_process(%__MODULE__{}), do: true
  def is_process(_), do: false
end
