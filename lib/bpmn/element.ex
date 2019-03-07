defmodule Bpmn.Element do
  alias Bpmn.Element.{Event, Activity, Gateway, SequenceFlow}
  alias Bpmn.Element.Event.Start, as: StartEvent
  alias Bpmn.Element.Event.End, as: EndEvent

  @type any_element() :: Event.t() | Activity.t() | Gateway.t() | SequenceFlow.t()
  @type source_element() :: StartEvent.t() | Activity.t() | Gateway.t()
  @type target_element() :: EndEvent.t() | Activity.t() | Gateway.t()

  def is_element(v) do
    Event.is_event(v) ||
      Activity.is_activity(v) ||
      Gateway.is_gateway(v) ||
      SequenceFlow.is_sequence_flow(v)
  end

  def is_source_element(v) do
    StartEvent.is_start_event(v) ||
      Activity.is_activity(v) ||
      Gateway.is_gateway(v)
  end

  def is_target_element(v) do
    EndEvent.is_end_event(v) ||
      Activity.is_activity(v) ||
      Gateway.is_gateway(v)
  end
end
