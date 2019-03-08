defmodule Bpmn.Element.Event.Start do
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
  end

  @spec is_start_event(any()) :: boolean()
  def is_start_event(%__MODULE__{}), do: true
  def is_start_event(_), do: false

  @spec decode(map()) :: {:ok, __MODULE__.t()} | :error
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> :error
    end
  end
end
