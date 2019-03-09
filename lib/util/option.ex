defmodule Util.Option do
  @type t(val_type, err_type) :: {:ok, val_type} | {:error, err_type}

  @spec map(t(any, any), (any -> any)) :: t(any, any)
  def map({:ok, val}, succ), do: {:ok, succ.(val)}
  def map(opt, _), do: opt

  @spec map(t(any, any), (any -> any), (any -> any)) :: t(any, any)
  def map({:ok, val}, succ, _), do: {:ok, succ.(val)}
  def map({:error, err}, _, fail), do: {:error, fail.(err)}

  # i dont even know...
  @spec flat(t(any, any)) :: any
  def flat({:ok, val}), do: val
  def flat({:error, {:ok, val}}), do: {:ok, val}
  def flat({:error, {:error, err}}), do: {:error, err}
  def flat(error), do: error

  @spec flat_map(t(any, any), (any -> t(any, any))) :: t(any, any)
  def flat_map(opt, succ), do: map(opt, succ) |> flat()

  @spec flat_map(t(any, any), (any -> t(any, any)), (any -> t(any, any))) :: t(any, any)
  def flat_map(opt, succ, fail), do: map(opt, succ, fail) |> flat()
end
