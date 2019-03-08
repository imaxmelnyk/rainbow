defmodule Bpmn.Element.Gateway do
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
