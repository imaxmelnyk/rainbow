defmodule Util.Option do
  @type t(val_type, err_type) :: {:ok, val_type} | {:error, err_type}

  @spec map(t(any, any), (any -> any)) :: t(any, any)
  def map({:ok, val}, succ), do: {:ok, succ.(val)}
  def map(err, _), do: err

  @spec map(t(any, any), (any -> any), (any -> any)) :: t(any, any)
  def map({:ok, val}, succ, _), do: {:ok, succ.(val)}
  def map({:error, err}, _, fail), do: {:error, fail.(err)}

  @spec flat_map(t(any, any), (any -> t(any, any))) :: t(any, any)
  def flat_map({:ok, val}, succ), do: succ.(val)
  def flat_map(err, _), do: err

  @spec flat_map(t(any, any), (any -> t(any, any)), (any -> t(any, any))) :: t(any, any)
  def flat_map({:ok, val}, succ, _), do: succ.(val)
  def flat_map({:error, err}, _, fail), do: fail.(err)
end