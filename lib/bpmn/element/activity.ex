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
  alias Bpmn.DecodeError
  alias Util.Option

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

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    case Map.pop(json, :subtype) do
      {"manual", json} -> ManualActivity.decode(json)
      _ -> {:error, DecodeError.create("Unknown activity type.")}
    end
  end
end
