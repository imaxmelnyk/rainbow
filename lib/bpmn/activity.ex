defmodule Bpmn.Activity do
  alias Bpmn.Activity.Manual, as: ManualActivity

  @type t :: ManualActivity.t()

  def is_activity(v) do
    ManualActivity.is_manual_actuvity(v)
  end
end
