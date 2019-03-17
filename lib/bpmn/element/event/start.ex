defmodule Bpmn.Element.Event.Start do
  alias Bpmn.Process.DecodeError
  alias Util.Option

  use Bpmn.Element.Event
  fields()

  @spec is_start_event(any()) :: boolean()
  def is_start_event(%__MODULE__{}), do: true
  def is_start_event(_), do: false

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> {:error, DecodeError.create("Error during decoding start event.")}
    end
  end
end
