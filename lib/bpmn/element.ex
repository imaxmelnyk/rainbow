defmodule Bpmn.Element do
  alias Bpmn.{Event, Activity, Gateway, SequenceFlow}
  alias Bpmn.Event.Start, as: StartEvent
  alias Bpmn.Event.End, as: EndEvent

  @type t :: Event.t() | Activity.t() | Gateway.t() | SequenceFlow.t()
  @type t_source :: StartEvent.t() | Activity.t() | Gateway.t()
  @type t_target :: EndEvent.t() | Activity.t() | Gateway.t()

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
