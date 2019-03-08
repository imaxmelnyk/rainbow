defmodule Bpmn.Element.Event.End do
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
  end

  @spec is_end_event(any()) :: boolean()
  def is_end_event(%__MODULE__{}), do: true
  def is_end_event(_), do: false

  @spec decode(map()) :: {:ok, __MODULE__.t()} | :error
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> :error
    end
  end
end
