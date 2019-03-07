defmodule Bpmn.Element.Event.Start do
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
  end

  def is_start_event(%__MODULE__{}), do: true
  def is_start_event(_), do: false
end