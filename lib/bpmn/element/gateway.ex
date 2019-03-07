defmodule Bpmn.Element.Gateway do
  alias Bpmn.Element.Gateway.Exclusive, as: ExclusiveGateway
  alias Bpmn.Element.Gateway.Parallel, as: ParallelGateway

  @type t() :: ExclusiveGateway.t() | ParallelGateway.t()

  def is_gateway(v) do
    ExclusiveGateway.is_exclusive_gateway(v) ||
      ParallelGateway.is_parallel_gateway(v)
  end
end
