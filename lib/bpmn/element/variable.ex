defmodule Bpmn.Element.Variable do
  alias Bpmn.DecodeError
  alias Util.Option
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
    field :value, String.t() | float() | boolean()
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
end
