defmodule Bpmn.Process.DecodeError do
  use TypedStruct
  typedstruct do
    field :message, String.t(),
      default: "Cannot decode bpmn process from the given json. Please, read the specification."
  end

  @spec create(String.t()) :: __MODULE__.t()
  def create(msg) do
    struct!(__MODULE__, message: msg)
  end

  @spec create() :: __MODULE__.t()
  def create(), do: struct!(__MODULE__)
end