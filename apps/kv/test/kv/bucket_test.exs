defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  alias KV.Bucket

  setup do
    { :ok, bucket } = Bucket.start_link()
    { :ok, bucket: bucket }
  end

  test "it stores values labeled with keys", %{ bucket: bucket } do
    assert Bucket.get(bucket, "foo") == nil

    Bucket.set(bucket, "foo", "bar")
    assert Bucket.get(bucket, "foo") == "bar"
  end

  test "it deletes and returns values labeled with keys", %{ bucket: bucket } do
    Bucket.set(bucket, "foo", "bar")
    assert Bucket.delete(bucket, "foo") == "bar"
    assert Bucket.get(bucket, "foo") == nil
  end
end

