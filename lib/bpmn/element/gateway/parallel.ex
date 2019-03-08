defmodule Bpmn.Element.Gateway.Parallel do
  alias Bpmn.DecodeError
  alias Util.Option
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
  end

  @spec is_parallel_gateway(any()) :: boolean()
  def is_parallel_gateway(%__MODULE__{}), do: true
  def is_parallel_gateway(_), do: false

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    try do
      {:ok, struct!(__MODULE__, json)}
    rescue
      _ -> {:error, DecodeError.create("Error during decoding parallel gateway.")}
    end
  end
end
