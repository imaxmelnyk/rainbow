defmodule Util.BooleanExpression.ParseError do
  defexception [message: "Error during parsing boolean expression."]

  @type t :: %__MODULE__{message: String.t}
end