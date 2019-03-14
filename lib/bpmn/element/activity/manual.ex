defmodule Bpmn.Element.Activity.Manual do
  alias Bpmn.Process.DecodeError
  alias Util.Option

  use Bpmn.Element.Activity
  fields()

  @spec is_manual_activity(any()) :: boolean()
  def is_manual_activity(%__MODULE__{}), do: true
  def is_manual_activity(_), do: false

  @spec decode(map()) :: Option.t(__MODULE__.t(), any())
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> {:error, DecodeError.create("Error during decoding manual activity.")}
    end
  end
end
