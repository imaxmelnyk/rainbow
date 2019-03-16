defmodule Util.Option do
  @type t(val_type, err_type) :: {:ok, val_type} | {:error, err_type}

  @spec map(t(any, any), (any -> any)) :: t(any, any)
  def map({:ok, val}, succ), do: {:ok, succ.(val)}
  def map({:error, err}, _), do: {:error, err}

  @spec map(t(any, any), (any -> any), (any -> any)) :: t(any, any)
  def map({:ok, val}, succ, _), do: {:ok, succ.(val)}
  def map({:error, err}, _, fail), do: {:error, fail.(err)}

  @spec flatten(t(t(any, any), any)) :: t(any, any)
  def flatten({:error, {:ok, val}}), do: {:ok, val}
  def flatten({:error, {:error, err}}), do: {:error, err}
  def flatten({:ok, {:error, err}}), do: {:error, err}
  def flatten({:ok, {:ok, val}}), do: {:ok, val}
  def flatten(error), do: error

  @spec flat_map(t(any, any), (any -> t(any, any))) :: t(any, any)
  def flat_map(opt, succ), do: map(opt, succ) |> flatten()

  @spec flat_map(t(any, any), (any -> t(any, any)), (any -> t(any, any))) :: t(any, any)
  def flat_map(opt, succ, fail), do: map(opt, succ, fail) |> flatten()

  @spec from_map(map) :: Option.t(map, any)
  def from_map(map) do
    map
    |> Enum.reduce_while({:ok, %{}}, fn {key, value}, {:ok, map} ->
      case value do
        {:ok, value} -> {:cont, {:ok, Map.put(map, key, value)}}
        {:error, err} -> {:halt, {:error, err}}
      end
    end)
  end

  @spec from_list(list) :: Option.t(list, any)
  def from_list(list) do
    list
    |> Enum.reduce_while({:ok, []}, fn value, {:ok, list} ->
      case value do
        {key, {:ok, value}} -> {:cont, {:ok, list ++ [{key, value}]}}
        {_key, {:error, err}} -> {:halt, {:error, err}}
        {:ok, value} -> {:cont, {:ok, list ++ [value]}}
        {:error, err} -> {:halt, {:error, err}}
      end
    end)
  end
end
