defmodule KVWeb do
  @moduledoc """
  A TCP server for a key-value store.
  """

  require Logger

  @ doc """
  Establish a connetion to the socket at `port`, listen for clients connecting
  to that port, and respond to those clients.
  """
  def accept(port) do
    options = [
      :binary, # Expect binary data (strings?) instead of lists (char lists?)
      packet: :line, # Split messages by newline
      active: false,  # Block until data is available
      reuseaddr: true # Use same address (port) if process crashes
    ]

    { :ok, socket } = :gen_tcp.listen(port, options)

    Logger.info "Accepting connections on port #{port}."
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    { :ok, client } = :gen_tcp.accept(socket)

    # Our application's `start` function starts a `Task.Supervisor` process
    # with the name `KVWeb.TaskSupervisor`, which we use here to identify that
    # process (rather than using its pid).
    # 
    # We spin up a child `Task` process to serve each newly connected client.
    { :ok, pid } = Task.Supervisor.start_child(KVWeb.TaskSupervisor, fn () ->
      serve(client)
    end)

    # Make the newly started `Task` process the "controlling process of the TCP
    # connection. This means that if the process running `loop_acceptor`
    # crashes all of the server processes will *not* crash, and they will be
    # able to continue serving responses to connected clients.
    :ok = :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket)
  end

  defp serve(client) do
    client
    |> read_line()
    |> write_line(client) 

    serve(client)
  end

  defp read_line(client) do
    { :ok, data } = :gen_tcp.recv(client, 0)
    data
  end

  defp write_line(line, client) do
    :gen_tcp.send(client, line)
  end
end

