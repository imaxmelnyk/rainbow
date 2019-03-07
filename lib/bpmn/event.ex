defmodule Bpmn.Event do
  alias Bpmn.Event.Start, as: StartEvent
  alias Bpmn.Event.End, as: EndEvent

  @type t :: StartEvent.t() | EndEvent.t()

  def is_event(v) do
    StartEvent.is_start_event(v) ||
      EndEvent.is_end_event(v)
  end
end
