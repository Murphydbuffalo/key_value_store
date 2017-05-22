defmodule KVWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Runs a supervisor with a `:simple_one_for_one` strategy so
      # that we can dynamically start new tasks
      supervisor(Task.Supervisor, [[name: KVWeb.TaskSupervisor]]),

      # Runs `Task.start_link(KVWeb, :accept, [4040])`
      worker(Task, [KVWeb, :accept, [4040]]),
    ]

    opts = [strategy: :one_for_one, name: KVWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

