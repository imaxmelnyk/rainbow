defmodule Bpmn.Process do
  alias Bpmn.Element
  alias Bpmn.Process.DecodeError
  alias Util.Option

  use TypedStruct
  typedstruct do
    field :id, integer(), enforce: true
    field :name, String.t()
    field :elements, [Element.any_element()], enforce: true
  end

  @spec is_process(any()) :: boolean()
  def is_process(%__MODULE__{}), do: true
  def is_process(_), do: false

  def parse_from_xml(xml) do
    import SweetXml

    empty_string_to_nil = fn str ->
      case str do
        "" -> nil
        _ -> str
      end
    end

    xml
    |> xmap(
      id: ~x"//bpmn:definitions/bpmn:process/@id"s,
      name: ~x"//bpmn:definitions/bpmn:process/@name"s,
      elements: [~x"//bpmn:definitions/bpmn:process",
        start_events: [~x"./bpmn:startEvent"l,
          id: ~x"./@id"s,
          name: ~x"./@name"s |> transform_by(empty_string_to_nil)
        ],
        end_events: [~x"./bpmn:endEvent"l,
          id: ~x"./@id"s,
          name: ~x"./@name"s |> transform_by(empty_string_to_nil)
        ],
        activities: [~x"./bpmn:task"l,
          id: ~x"./@id"s,
          name: ~x"./@name"s |> transform_by(empty_string_to_nil)
        ],
        sequence_flows: [~x"./bpmn:sequenceFlow"l,
          id: ~x"./@id"s,
          name: ~x"./@name"s |> transform_by(empty_string_to_nil),
          source: ~x"./@sourceRef"s,
          target: ~x"./@targetRef"s,
          is_allowed: ~x"./bpmn:conditionExpression/text()"s |> transform_by(empty_string_to_nil),
        ],
        exclusive_gateways: [~x"./bpmn:exclusiveGateway"l,
          id: ~x"./@id"s,
          name: ~x"./@name"s |> transform_by(empty_string_to_nil)
        ],
        parallel_gateways: [~x"./bpmn:parallelGateway"l,
          id: ~x"./@id"s,
          name: ~x"./@name"s |> transform_by(empty_string_to_nil)
        ]
      ]
    )
    |> Map.update!(:elements, fn elements ->
      Enum.reduce(elements, [], fn {key, value}, acc ->
        case key do
          :start_events -> acc ++ Enum.map(value, fn start_event ->
            start_event
            |> Map.put(:type, "event")
            |> Map.put(:subtype, "start")
          end)
          :end_events -> acc ++ Enum.map(value, fn end_event ->
            end_event
            |> Map.put(:type, "event")
            |> Map.put(:subtype, "end")
          end)
          :activities -> acc ++ Enum.map(value, fn activity ->
            activity
            |> Map.put(:type, "activity")
            |> Map.put(:subtype, "manual")
          end)
          :sequence_flows -> acc ++ Enum.map(value, fn sequence_flow ->
            sequence_flow
            |> Map.put(:type, "sequence-flow")
          end)
          :exclusive_gateways -> acc ++ Enum.map(value, fn exclusive_gateway ->
            exclusive_gateway
            |> Map.put(:type, "gateway")
            |> Map.put(:subtype, "exclusive")
          end)
          :parallel_gateways -> acc ++ Enum.map(value, fn parallel_gateway ->
            parallel_gateway
            |> Map.put(:type, "gateway")
            |> Map.put(:subtype, "parallel")
          end)
        end
      end)
    end)
    |> decode()
  end

  @spec decode(map()) :: Option.t(__MODULE__.t(), any())
  def decode(json) do
    json
    |> Map.fetch(:elements)
    |> (fn elements ->
      case elements do
        :error -> {:error, DecodeError.create("Error during decoding process.")}
        ok -> ok
      end
    end).()
    |> Option.flat_map(fn elements ->
      elements
      |> Enum.reduce_while({:ok, []}, fn elem, {:ok, acc} ->
        case Element.decode(elem) do
          {:ok, elem} -> {:cont, {:ok, [elem | acc]}}
          error -> {:halt, error}
        end
      end)
    end)
    |> Option.flat_map(fn elements ->
      try do
        {:ok, struct!(__MODULE__, %{json | elements: elements})}
      rescue
        _ -> {:error, DecodeError.create("Error during decoding process.")}
      end
    end)
  end
end
