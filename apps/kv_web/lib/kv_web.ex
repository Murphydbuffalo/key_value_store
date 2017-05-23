defmodule KVWeb do
  @moduledoc """
  A TCP server for a key-value store.
  """

  require Logger
  alias KVWeb.Parser
  alias KVWeb.KVInterface

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
    message = :gen_tcp.recv(client, 0)
    handle_message(client, message)

    serve(client)
  end

  defp handle_message(client, {:ok, data }) do
    command = Parser.parse(data)
    respond(client, command)
  end

  defp handle_message(_client, {:error, _err }) do
    Logger.info "CLIENT DISCONNECTED\n\n"
    exit(:normal)
  end

  defp respond(client, { :ok, command }) do
    response = KVInterface.run(command)
    :gen_tcp.send(client, response)
  end

  defp respond(client, {:error, :invalid_command }) do
    :gen_tcp.send(client, "INVALID COMMAND\n\n")
  end
end

