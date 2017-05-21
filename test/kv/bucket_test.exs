defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  alias KV.Bucket

  test "it stores values labeled with keys" do
    { :ok, bucket } = Bucket.create("test_bucket")
    assert Bucket.get(bucket, "foo") == nil

    Bucket.set(bucket, "foo", "bar")
    assert Bucket.get(bucket, "foo") == "bar"
  end
end

