defmodule Bpmn.Element do
  alias Bpmn.Element.{Event, Activity, Gateway, SequenceFlow, Variable}
  alias Bpmn.Element.Event.Start, as: StartEvent
  alias Bpmn.Element.Event.End, as: EndEvent

  @type any_element() :: Event.t() | Activity.t() | Gateway.t() | SequenceFlow.t() | Variable.t()
  @type source_element() :: StartEvent.t() | Activity.t() | Gateway.t()
  @type target_element() :: EndEvent.t() | Activity.t() | Gateway.t()

  @spec is_element(any()) :: boolean()
  def is_element(v) do
    Event.is_event(v) ||
      Activity.is_activity(v) ||
      Gateway.is_gateway(v) ||
      SequenceFlow.is_sequence_flow(v) ||
      Variable.is_variable(v)
  end

  @spec is_source_element(any()) :: boolean()
  def is_source_element(v) do
    StartEvent.is_start_event(v) ||
      Activity.is_activity(v) ||
      Gateway.is_gateway(v)
  end

  @spec is_target_element(any()) :: boolean()
  def is_target_element(v) do
    EndEvent.is_end_event(v) ||
      Activity.is_activity(v) ||
      Gateway.is_gateway(v)
  end
end
