defmodule KV.Supervisor do
  use Supervisor
  alias KV.Registry.Client, as: Registry

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Registry, [Registry])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

