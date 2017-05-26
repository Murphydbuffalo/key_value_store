defmodule KV.Router do
  @doc """
  Dispatches a function all to another node based on the name of the `bucket`.
  """

  def route(bucket, module, func, args) do
    <<first_char :: size(8), _rest :: binary>> = bucket

    with {_range, node} <- match_bucket_to_node(first_char)
    do
      Task.Supervisor.async({KV.Router, node}, module, func, args) |> Task.await()
    else
      _err -> raise "No matching node found in #{inspect(routing_table())} for bucket #{bucket}."
    end
  end

  defp match_bucket_to_node(bucket_first_character) do
    Enum.find(routing_table(), fn ({range, _node}) ->
      Enum.member?(range, bucket_first_character)
    end)
  end

  defp routing_table, do: Application.fetch_env!(:kv, :routing_table)
end

