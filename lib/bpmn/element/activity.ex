defmodule Bpmn.Element.Activity do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [fields: 0, fields: 1]
    end
  end

  defmacro fields(do: new_fields) do
    use Bpmn.Element
    quote do
      fields do
        field :is_allowed, unquote(__MODULE__).t_is_allowed(), default: &unquote(__MODULE__).is_allowed/1
        field :execute, unquote(__MODULE__).t_execute(), default: &unquote(__MODULE__).execute/1
        unquote(new_fields)
      end
    end
  end

  defmacro fields() do
    quote do
      fields do: nil
    end
  end

  alias Bpmn.Element.Activity.Manual, as: ManualActivity
  alias Bpmn.Element.Variable
  alias Bpmn.Process.DecodeError
  alias Util.Option
  alias Util.BooleanExpression

  @type t() :: ManualActivity.t()
  @type t_is_allowed() :: ([Variable.t()] -> boolean())
  @type t_execute() :: ([Variable.t()] -> [Variable.t()])

  @spec is_activity(any()) :: boolean()
  def is_activity(v) do
    ManualActivity.is_manual_activity(v)
  end

  @doc """
  Default function for activities.
  Meaning: activity is always allowed.
  """
  @spec is_allowed([Variable.t()]) :: boolean()
  def is_allowed(_), do: true

  @doc """
  Default function for activities.
  Meaning: activity change nothing.
  """
  @spec execute([Variable.t()]) :: [Variable.t()]
  def execute(vars), do: vars

  @spec decode(map()) :: Option.t(__MODULE__.t(), any())
  def decode(json) do
    is_allowed_option =
      case Map.get(json, :is_allowed) do
        nil -> {:ok, &__MODULE__.is_allowed/1}
        expr when is_binary(expr) -> decode_boolean_expression(expr)
        _ -> {:error, DecodeError.create()}
      end

    is_allowed_option
    |> Option.map(&(Map.put(json, :is_allowed, &1)))
    |> Option.flat_map(fn json ->
      case Map.pop(json, :subtype) do
        {"manual", json} -> ManualActivity.decode(json)
        _ -> {:error, DecodeError.create("Unknown activity type.")}
      end
    end)
  end

  @spec decode_boolean_expression(String.t()) :: ([Variable.t()] -> boolean())
  defp decode_boolean_expression(expr) do
    expr
      |> BooleanExpression.parse()
      |> Option.map(fn expr ->
        fn variables ->
          case BooleanExpression.exec(expr, Variable.list_to_map(variables)) do
            {:ok, val} -> val
            {:error, _err} -> false
          end
        end
      end)
  end
end
