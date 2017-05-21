defmodule KV.Bucket do
  @doc """
  Creates a new bucket. This starts an agent process with an empty map as its state.
  """
  def create(name), do: Agent.start_link(fn -> %{} end)

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
end

