defmodule Bpmn.Element.SequenceFlow do
  alias Bpmn.Process.DecodeError
  alias Util.Option
  alias Util.BooleanExpression

  use Bpmn.Element
  fields do
    field :is_allowed, __MODULE__.t_is_allowed(), default: &__MODULE__.is_allowed/1
    field :source, String.t(), enforce: true
    field :target, String.t(), enforce: true
  end

  @type t_is_allowed() :: (map() -> boolean())

  @doc """
  Default value.
  Sequence flow is always allowed.
  """
  @spec is_allowed(map()) :: boolean()
  def is_allowed(_), do: true

  @spec is_sequence_flow(any()) :: boolean()
  def is_sequence_flow(%__MODULE__{}), do: true
  def is_sequence_flow(_), do: false

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    case Map.get(json, :is_allowed) do
      nil -> {:ok, &__MODULE__.is_allowed/1}
      expr when is_binary(expr) ->
        expr
        |> BooleanExpression.parse()
        |> Option.map(fn expr ->
          fn variables ->
            case BooleanExpression.exec(expr, variables) do
              {:ok, result} -> result
              {:error, _err} -> false
            end
          end
        end)
    end
    |> Option.map(&(Map.put(json, :is_allowed, &1)))
    |> Option.flat_map(fn json ->
      try do
        {:ok, struct!(__MODULE__, json)}
      rescue
        _ -> {:error, DecodeError.create("Error during decoding sequence flow.")}
      end
    end)
  end
end
