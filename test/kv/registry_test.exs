defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  alias KV.Registry.Client, as: Registry

  setup do
    { :ok, server } = Registry.start_link()
    Registry.create(server, "Dan's Bucket")
  end
 
  test "it retrieves a bucket pid by name", %{ server: server } do
    { :reply, bucket } = Registry.lookup(server, "Dan's Bucket")
    assert is_pid(bucket)
  end

  test "it returns the bucket process with an existing name", %{ server: server } do
    { :reply, original_bucket_pid } = Registry.lookup(server, "Dan's Bucket")
    Registry.create(server, "Dan's Bucket")
    { :reply, new_bucket_pid } = Registry.lookup(server, "Dan's Bucket")

    assert original_bucket_pid == new_bucket_pid
  end
end

