defmodule Bpmn.Element.Activity.Manual do
  alias Bpmn.Element.Activity
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
    field :is_allowed, Activity.t_is_allowed(), default: &Activity.is_allowed/1
    field :execute, Activity.t_execute(), default: &Activity.execute/1
  end

  @spec is_manual_activity(any()) :: boolean()
  def is_manual_activity(%__MODULE__{}), do: true
  def is_manual_activity(_), do: false

  @spec decode(map()) :: {:ok, __MODULE__.t()} | :error
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> :error
    end
  end
end
