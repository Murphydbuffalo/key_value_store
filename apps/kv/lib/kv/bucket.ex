defmodule KV.Bucket do
  @doc """
  Creates a new bucket. This starts an agent process with an empty map as its state.
  """
  def start_link(), do: Agent.start_link(fn -> %{} end)

  @doc """
  Sets the value for a given key in the bucket.
  """
  def set(bucket, key, value) do
    Agent.update(bucket, fn (map) -> Map.put(map, key, value) end)
  end

  @doc """
  Gets the value for a given key in the bucket.
  """
  def get(bucket, key) do
    Agent.get(bucket, fn (map) -> Map.get(map, key) end)
  end

  @doc """
  Removes and returns the value for a given key in the bucket.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn (map) -> Map.pop(map, key) end)
  end
end

