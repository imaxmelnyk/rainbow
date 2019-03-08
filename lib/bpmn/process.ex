defmodule Bpmn.Process do
  alias Bpmn.Element
  alias Bpmn.DecodeError
  alias Util.Option
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
    field :elements, [Element.any_element()], enforce: true
  end

  @spec is_process(any()) :: boolean()
  def is_process(%__MODULE__{}), do: true
  def is_process(_), do: false

  @spec decode(map()) :: Option.t(__MODULE__.t(), any())
  def decode(json) do
    json
    |> Map.fetch(:elements)
    |> Option.flat_map(fn elements ->
      elements
      |> Enum.reduce_while({:ok, []}, fn elem, {:ok, acc} ->
        case Element.decode(elem) do
          {:ok, elem} -> {:cont, {:ok, [elem | acc]}}
          error -> {:halt, error}
        end
      end)
    end)
    |> Option.flat_map(fn elements ->
      try do
        {:ok, struct!(__MODULE__, %{json | elements: elements})}
      rescue
        _ -> {:error, DecodeError.create("Error during decoding process.")}
      end
    end)
    |> Option.flat_map(&(grow(&1)))
  end

  @spec grow(__MODULE__.t()) :: Option.t(__MODULE__.t(), any())
  def grow(process) do
    process.elements
    |> Enum.reduce_while({:ok, []}, fn elem, {:ok, acc} ->
      case Element.grow(process.elements, elem) do
        {:ok, elem} -> {:cont, {:ok, [elem | acc]}}
        error -> {:halt, error}
      end
    end)
    |> Option.flat_map(&(struct!(process, [elements: &1])))
  end
end

defmodule Bpmn.DecodeError do
  use TypedStruct

  typedstruct do
    field :message, String.t(),
      default: "Cannot decode bpmn process from the given json. Please, read the specification."
  end

  @spec create(String.t()) :: __MODULE__.t()
  def create(msg) do
    struct!(__MODULE__, message: msg)
  end

  @spec create() :: __MODULE__.t()
  def create(), do: struct!(__MODULE__)
end
