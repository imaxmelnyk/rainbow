defmodule Util.BooleanExpression.ExecError do
  defexception [message: "Error during execution boolean expression."]

  @type t :: %__MODULE__{message: String.t}
end