defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  alias KV.Registry.Client, as: Registry
  alias KV.Bucket

  setup context do
    { :ok, server } = Registry.start_link(context.test)
    Registry.create(server, "Dan's Bucket")
    { :ok, server: server }
  end
 
  test "it retrieves a bucket pid by name", %{ server: server } do
    { :ok, bucket } = Registry.lookup(server, "Dan's Bucket")
    assert is_pid(bucket)

    Bucket.set(bucket, "cow", "moo")
    assert Bucket.get(bucket, "cow") == "moo"
  end

  test "it returns the bucket process with an existing name", %{ server: server } do
    { :ok, original_bucket_pid } = Registry.lookup(server, "Dan's Bucket")
    Registry.create(server, "Dan's Bucket")
    { :ok, new_bucket_pid } = Registry.lookup(server, "Dan's Bucket")

    assert original_bucket_pid == new_bucket_pid
  end
end

