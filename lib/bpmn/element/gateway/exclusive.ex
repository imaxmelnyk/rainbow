defmodule Bpmn.Element.Gateway.Exclusive do
  alias Bpmn.DecodeError
  alias Util.Option
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
  end

  @spec is_exclusive_gateway(any()) :: boolean()
  def is_exclusive_gateway(%__MODULE__{}), do: true
  def is_exclusive_gateway(_), do: false

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> {:error, DecodeError.create("Error during decoding exclusive gateway.")}
    end
  end
end
