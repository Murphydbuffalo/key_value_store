defmodule KV do
  @moduledoc """
  A distributed key-value store.
  """
  
  use Application

  def start(_type, _args) do
    KV.Supervisor.start_link()
  end
end

