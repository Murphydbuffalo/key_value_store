defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  alias KV.Bucket

  setup do
    { :ok, bucket } = Bucket.create("test_bucket")
    { :ok, bucket: bucket }
  end

  test "it stores values labeled with keys", %{bucket: bucket } do
    assert Bucket.get(bucket, "foo") == nil

    Bucket.set(bucket, "foo", "bar")
    assert Bucket.get(bucket, "foo") == "bar"
  end
end

