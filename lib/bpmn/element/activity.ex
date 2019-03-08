defmodule Bpmn.Element.Activity do
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
