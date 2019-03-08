defmodule Bpmn.Process do
  alias Bpmn.Element
  alias Bpmn.ProcessDecodeError
  use TypedStruct

  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
    field :elements, [Element.any_element()], enforce: true
  end

  @spec is_process(any()) :: boolean()
  def is_process(%__MODULE__{}), do: true
  def is_process(_), do: false

  @spec decode(map()) :: {:ok, __MODULE__.t()} | {:error, ProcessDecodeError.t()}
  def decode(json) do
    case Map.fetch(json, :elements) do
      {:ok, elements} when is_list(elements) ->
        elements =
          Enum.reduce_while(elements, {:ok, []}, fn elem, {:ok, acc} ->
            case Element.decode(elem) do
              {:ok, elem} -> {:cont, {:ok, [elem | acc]}}
              _ -> {:halt, :error}
            end
          end)

        case elements do
          {:ok, elements} ->
            json = %{json | elements: elements}

            process =
              try do
                {:ok, struct!(__MODULE__, json)}
              rescue
                _ -> :error
              end

            case process do
              {:ok, process} ->
                # do we really need to grow ?
                case grow(process) do
                  {:ok, process} -> {:ok, process}
                  _ -> {:error, ProcessDecodeError.create("Error during growing process.")}
                end
              _ -> {:error, ProcessDecodeError.create("Error during decoding process.")}
            end
          _ -> {:error, ProcessDecodeError.create("Error during decoding elements.")}
        end
      _ -> {:error, ProcessDecodeError.create("Elements has not been found.")}
    end
  end

  @spec grow(__MODULE__.t()) :: {:ok, __MODULE__.t()} | :error
  def grow(process) do
    elements = process.elements

    elements =
      Enum.reduce_while(elements, {:ok, []}, fn elem, {:ok, acc} ->
        case Element.grow(elements, elem) do
          {:ok, elem} -> {:cont, {:ok, [elem | acc]}}
          _ -> {:halt, :error}
        end
      end)

    case elements do
      {:ok, elements} -> {:ok, struct!(process, elements: elements)}
      _ -> :error
    end
  end
end

defmodule Bpmn.ProcessDecodeError do
  use TypedStruct

  typedstruct do
    field :message, String.t(),
      default: "Cannot decode bpmn process from the given json. Please, read the specification."
  end

  @spec create(String.t()) :: __MODULE__.t()
  def create(msg) do
    struct!(ProcessDecodeError, message: msg)
  end

  @spec create() :: __MODULE__.t()
  def create(), do: struct!(ProcessDecodeError)
end
