defmodule Bpmn.Element.Event do
  alias Bpmn.Element.Event.Start, as: StartEvent
  alias Bpmn.Element.Event.End, as: EndEvent

  @type t() :: StartEvent.t() | EndEvent.t()

  @spec is_event(any()) :: boolean()
  def is_event(v) do
    StartEvent.is_start_event(v) ||
      EndEvent.is_end_event(v)
  end

  @spec decode(map()) :: {:ok, __MODULE__.t()} | :error
  def decode(json) do
    case Map.pop(json, :subtype) do
      {"start", json} -> StartEvent.decode(json)
      {"end", json} -> EndEvent.decode(json)
      _ -> :error
    end
  end
end
