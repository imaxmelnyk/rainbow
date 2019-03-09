defmodule Bpmn.Element.Event.End do
  alias Bpmn.DecodeError
  alias Util.Option

  use Bpmn.Element.Event
  fields()

  @spec is_end_event(any()) :: boolean()
  def is_end_event(%__MODULE__{}), do: true
  def is_end_event(_), do: false

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> {:error, DecodeError.create("Error during decoding end event.")}
    end
  end
end
