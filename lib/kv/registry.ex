defmodule KV.Registry do
  defmodule Client do
    @doc """
      Starts the registry.
    """
    def start_link, do: GenServer.start_link(KV.Registry.Server, :ok, [])


    @doc """
      Ensures there is a bucket associated to the given `name` in `server`.
    """
    def create(server, name), do: GenServer.cast(server, {:create, name})

    @doc """
      Looks up the bucket pid for `name` stored in `server`.
      Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
    """
    def lookup(server, name), do: GenServer.call(server, {:lookup, name}) 
  end

  defmodule Server do
    use GenServer

    alias KV.Bucket

    def init(:ok), do: { :ok, %{} }

    def handle_call({:lookup, name}, _client, names) do
      { :reply, Map.fetch(names, name), names }
    end

    def handle_cast({:create, name}, names) do
      if Map.has_key?(names, name) do
        { :no_reply, names }
      else
        { :ok, pid } = Bucket.create()
        { :noreply, Map.put(names, name, pid) }
      end
    end
  end
end

