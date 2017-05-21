defmodule KV.Registry do
  defmodule Client do
    @doc """
      Starts the registry.
    """
    def start_link, do: GenServer.start_link(KV.Registry.Server, :ok, [])


    @doc """
      Ensures there is a bucket associated to the given `name` in `server`.
      In a real application this would probably be a call, but this guide
      wants to demonstrate how casts work too.
    """
    def create(server, name), do: GenServer.cast(server, {:create, name})

    @doc """
      Looks up the bucket pid for `name` stored in `server`.
      Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
    """
    def lookup(server, name), do: GenServer.call(server, {:lookup, name}) 

    def stop(server), do: GenServer.stop(server)
  end

  defmodule Server do
    use GenServer

    alias KV.Bucket

    def init(:ok), do: { :ok, %{ names: %{}, refs: %{} } }

    def handle_call({:lookup, name}, _client, state = %{ names: names, refs: _refs }) do
      { :reply, Map.fetch(names, name), state }
    end

    def handle_cast({:create, name}, state = %{ names: names, refs: refs }) do
      if Map.has_key?(names, name) do
        { :noreply, state }
      else
        { :ok, pid } = Bucket.start_link()
        ref = Process.monitor(pid)

        refs = Map.put(refs, ref, name)
        names = Map.put(names, name, pid)
        { :noreply, %{ names: names, refs: refs }}
      end
    end

    def handle_info({ :DOWN, ref, :process, _pid, _reason }, %{ names: names, refs: refs }) do
      name = Map.get(refs, ref)
      names = Map.delete(names, name)
      { :noreply, %{ names: names, refs: refs }}
    end

    def handle_info(_message, state) do
      { :noreply, state }
    end

  end
end

