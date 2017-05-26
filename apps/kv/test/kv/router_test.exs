defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed
  test "functions are called on different nodes based on a passed-in bucket name" do
    assert KV.Router.route("a_bucket", Kernel, :node, []) == :"chomsky@Dans-MacBook-Pro"
    assert KV.Router.route("z_bucket", Kernel, :node, []) == :"foucault@Dans-MacBook-Pro"
  end

  test "raises an error when a matching node can't be found for a bucket name" do
    assert_raise RuntimeError, fn ->
      KV.Router.route("é_bucket", Kernel, :node, [])
    end
  end
end

