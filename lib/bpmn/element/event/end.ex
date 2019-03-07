defmodule Bpmn.Element.Event.End do
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
  end

  def is_end_event(%__MODULE__{}), do: true
  def is_end_event(_), do: false
end
