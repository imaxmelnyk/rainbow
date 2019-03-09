defmodule Bpmn.Element.Gateway do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [fields: 0, fields: 1]
    end
  end

  defmacro fields(do: new_fields) do
    use Bpmn.Element
    quote do
      fields do
        unquote(new_fields)
      end
    end
  end

  defmacro fields() do
    quote do
      fields do: nil
    end
  end

  alias Bpmn.Element.Gateway.Exclusive, as: ExclusiveGateway
  alias Bpmn.Element.Gateway.Parallel, as: ParallelGateway
  alias Bpmn.DecodeError
  alias Util.Option

  @type t() :: ExclusiveGateway.t() | ParallelGateway.t()

  @spec is_gateway(any()) :: boolean()
  def is_gateway(v) do
    ExclusiveGateway.is_exclusive_gateway(v) ||
      ParallelGateway.is_parallel_gateway(v)
  end

  @spec decode(map()) :: Option.t(__MODULE__.t(), DecodeError.t())
  def decode(json) do
    case Map.pop(json, :subtype) do
      {"exclusive", json} -> ExclusiveGateway.decode(json)
      {"parallel", json} -> ParallelGateway.decode(json)
      _ -> {:error, DecodeError.create("Unknown gateway type.")}
    end
  end
end
