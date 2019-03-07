defmodule Bpmn.Element.Activity.Manual do
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
  end

  def is_manual_activity(%__MODULE__{}), do: true
  def is_manual_activity(_), do: false
end
