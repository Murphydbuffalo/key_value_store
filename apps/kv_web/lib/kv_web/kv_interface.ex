defmodule KVWeb.KVInterface do
  @moduledoc """
  Call functions provided by the `kv` application.
  """

  alias KV.Registry.Client, as: Registry
  alias KV.Bucket

  @ok_message "OK\n\n"

  def run({ :create, bucket }) do
    Registry.create(Registry, bucket)
    @ok_message
  end

  def run({ :get, bucket, key }) do
    lookup_bucket(bucket, fn (pid) ->
      value = Bucket.get(pid, key)
      "#{value}\n#{@ok_message}"
    end)
  end

  def run({ :set, bucket, key, value }) do
    lookup_bucket(bucket, fn (pid) ->
      Bucket.set(pid, key, value)
      @ok_message
    end)
  end

  def run({ :delete, bucket, key }) do
    lookup_bucket(bucket, fn (pid) ->
      Bucket.delete(pid, key)
      @ok_message
    end)
  end

  defp lookup_bucket(bucket_name, callback) do
    case Registry.lookup(Registry, bucket_name) do
      {:ok, pid} -> callback.(pid)
      :error -> "Bucket \"#{bucket_name}\" not found.\n\n"
    end
  end
end

