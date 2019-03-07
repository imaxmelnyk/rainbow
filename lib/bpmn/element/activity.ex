defmodule Bpmn.Element.Activity do
  alias Bpmn.Element.Activity.Manual, as: ManualActivity

  @type t() :: ManualActivity.t()

  def is_activity(v) do
    ManualActivity.is_manual_activity(v)
  end
end
