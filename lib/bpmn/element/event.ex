defmodule Bpmn.Element.Event do
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

  alias Bpmn.Element.Event.Start, as: StartEvent
  alias Bpmn.Element.Event.End, as: EndEvent
  alias Bpmn.Process.DecodeError
  alias Util.Option

  @type t() :: StartEvent.t() | EndEvent.t()

  @spec is_event(any()) :: boolean()
  def is_event(v) do
    StartEvent.is_start_event(v) ||
      EndEvent.is_end_event(v)
  end

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    case Map.pop(json, :subtype) do
      {"start", json} -> StartEvent.decode(json)
      {"end", json} -> EndEvent.decode(json)
      _ -> {:error, DecodeError.create("Unknown event type.")}
    end
  end
end
