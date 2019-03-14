defmodule Bpmn.Element.Variable do
  alias Bpmn.Process.DecodeError
  alias Util.Option

  use Bpmn.Element
  fields do
    field :value, number() | boolean()
  end

  @spec is_variable(any()) :: boolean()
  def is_variable(%__MODULE__{}), do: true
  def is_variable(_), do: false

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> {:error, DecodeError.create("Error during decoding variable.")}
    end
  end

  @spec list_to_map([__MODULE__.t()]) :: map()
  def list_to_map(variables) do
    Enum.reduce(variables, %{}, fn variable, map ->
      Map.put(map, variable.name, variable.value)
    end)
  end
end
