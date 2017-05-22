defmodule KV.Bucket.Supervisor do
  @moduledoc """
  A supervisor for starting `Bucket` processes.
  This allows us to avoid having the registry directly start buckets,
  which would then crash the registry whenever they crashed.
  """

  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, [name: __MODULE__])
  def start_bucket, do: Supervisor.start_child(__MODULE__, [])

  @doc """
  We do not want to restart buckets when they crash, so we have set
  the worker `restart:` option to `:temporary`.

  We want to dynamically start up bucket workers, so we have set
  the supervisor `strategy:` to `:simple_one_for_one`.
  """
  def init(:ok) do 
    children = [
      worker(KV.Bucket, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end

