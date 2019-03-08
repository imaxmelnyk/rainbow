defmodule Bpmn.Element.Event do
  alias Bpmn.Element.Event.Start, as: StartEvent
  alias Bpmn.Element.Event.End, as: EndEvent
  alias Bpmn.DecodeError
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
