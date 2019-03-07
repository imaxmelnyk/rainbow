defmodule Bpmn.Process do
  alias Bpmn.Element

  @enforce_keys [:id, :elements]
  defstruct [:id, :name, :elements]

  @type t :: %__MODULE__{id: integer, elements: [Element.t()]}

  def is_process(%__MODULE__{}), do: true
  def is_process(_), do: false
end
