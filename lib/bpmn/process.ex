defmodule Bpmn.Process do
  alias Bpmn.Element
  alias Bpmn.Process.DecodeError
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
    |> (fn elements ->
      case elements do
        :error -> {:error, DecodeError.create("Error during decoding process.")}
        ok -> ok
      end
    end).()
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
  end
end
