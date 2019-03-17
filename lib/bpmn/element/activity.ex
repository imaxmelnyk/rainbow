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
  alias Bpmn.Process.DecodeError
  alias Util.Option

  @type t() :: ManualActivity.t()

  @spec is_activity(any()) :: boolean()
  def is_activity(v) do
    ManualActivity.is_manual_activity(v)
  end

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    case Map.pop(json, :subtype) do
      {nil, json} -> ManualActivity.decode(json)
      {"manual", json} -> ManualActivity.decode(json)
      _ -> {:error, DecodeError.create("Unknown activity type.")}
    end
  end
end
