defmodule KV.Registry do
  defmodule Client do
    @doc """
      Starts the registry.
    """
    def start_link(name), do: GenServer.start_link(KV.Registry.Server, name, [name: name])


    @doc """
      Ensures there is a bucket associated to the given `name` in `server`.
      In a real application this would probably be a call, but this guide
      wants to demonstrate how casts work too.
    """
    def create(server, name), do: GenServer.call(server, {:create, name})

    @doc """
      Looks up the bucket pid for `name` stored in `ets_table`.
      Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
    """
    def lookup(names, name) when is_atom(names) do
      case :ets.lookup(names, name) do
        [{^name, pid}] -> { :ok, pid }
        [] -> :error
      end
    end

    def stop(server), do: GenServer.stop(server)
  end

  defmodule Server do
    use GenServer

    alias KV.Bucket.Supervisor, as: BucketSupervisor

    def init(name) do
      names = :ets.new(name, [:set, :protected, :named_table, read_concurrency: true])
      { :ok, %{ names: names, refs: %{} }}
    end

    def handle_call({:create, name}, _client, state = %{ names: names, refs: refs }) do
      case KV.Registry.Client.lookup(names, name) do
        { :ok, _pid } ->
          { :reply, { :ok, name }, state }
        :error ->
          { :ok, pid } = BucketSupervisor.start_bucket()
          ref = Process.monitor(pid)
          refs = Map.put(refs, ref, name)
          :ets.insert(names, {name, pid})

          { :reply, { :ok, name }, %{ names: names, refs: refs }}
      end
    end

    def handle_info({ :DOWN, ref, :process, _pid, _reason }, %{ names: names, refs: refs }) do
      name = Map.get(refs, ref)
      :ets.delete(names, name)
      { :noreply, %{ names: names, refs: refs }}
    end

    def handle_info(_message, state) do
      { :noreply, state }
    end
  end
end

