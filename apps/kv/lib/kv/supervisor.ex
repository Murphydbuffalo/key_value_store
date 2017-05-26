defmodule KV.Supervisor do
  use Supervisor
  alias KV.Registry.Client, as: Registry
  alias KV.Bucket.Supervisor, as: BucketSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Registry, [Registry]),
      supervisor(BucketSupervisor, []),
      supervisor(Task.Supervisor, [[name: KV.Router]])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end

