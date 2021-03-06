defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  alias KV.Registry.Client, as: Registry
  alias KV.Bucket

  setup context do
    Registry.start_link(context.test)
    Registry.create(context.test, "Dan's Bucket")
    { :ok, registry_name: context.test }
  end
 
  test "it retrieves a bucket pid by name", %{ registry_name: registry_name } do
    { :ok, bucket } = Registry.lookup(registry_name, "Dan's Bucket")
    assert is_pid(bucket)

    # Make sure the pid retrieved points to a `Bucket` process.
    Bucket.set(bucket, "cow", "moo")
    assert Bucket.get(bucket, "cow") == "moo"
  end

  test "it returns the bucket process with an existing name", %{ registry_name: registry_name } do
    { :ok, original_bucket_pid } = Registry.lookup(registry_name, "Dan's Bucket")
    Registry.create(registry_name, "Dan's Bucket")
    { :ok, new_bucket_pid } = Registry.lookup(registry_name, "Dan's Bucket")

    assert original_bucket_pid == new_bucket_pid
  end

  test "it clears out names for crashed bucket processes", %{ registry_name: registry_name } do
    { :ok, bucket } = Registry.lookup(registry_name, "Dan's Bucket")
    Process.exit(bucket, :abnormal_exit)
    ref = Process.monitor(bucket)

    assert_receive { :DOWN, ^ref, :process, ^bucket, _reason }

    # Send a synchronousm message to the registry and wait for the reply
    # to ensure that it had time to process the :DOWN message from the monitor.
    # We need to do this because `handle_info` is asynchronous, and so without
    # awaiting the result of the sychronous call there is
    # no guarantee that the Registry has removed the name of the dead bucket
    # by the time we make the assertion at the end of this test.
    Registry.create(registry_name, "just a dummy bucket")

    assert Registry.lookup(registry_name, "Dan's Bucket") == :error
  end
end

