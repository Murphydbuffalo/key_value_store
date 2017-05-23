defmodule KVWeb.Parser do
  @moduledoc """
  Parse incoming TCP requests and convert them into valid commands for the `kv`
  application.
  """

  @doc ~S"""
  Parses a `command` for use by the `kv` application.

  ## Examples

      iex> KVWeb.Parser.parse "CREATE groceries\r\n"
      { :ok, { :create, "groceries" }}

      iex> KVWeb.Parser.parse "CREATE groceries"
      { :ok, { :create, "groceries" }}

      iex> KVWeb.Parser.parse "SET groceries eggs 12"
      { :ok, { :set, "groceries", "eggs", "12" }}

      iex> KVWeb.Parser.parse "GET groceries eggs"
      { :ok, { :get, "groceries", "eggs" }}

      iex> KVWeb.Parser.parse "DELETE groceries eggs"
      { :ok, { :delete, "groceries", "eggs" }}

      iex> KVWeb.Parser.parse "FOO groceries eggs"
      { :error, :invalid_command }

      iex> KVWeb.Parser.parse "GET groceries"
      { :error, :invalid_command }
    
      iex> KVWeb.Parser.parse "CREATE"
      { :error, :invalid_command }

      iex> KVWeb.Parser.parse "DELETE"
      { :error, :invalid_command }

      iex> KVWeb.Parser.parse "SET groceries soup"
      { :error, :invalid_command }

  """
  def parse(command) do
    case String.split(command) do
      ["CREATE", bucket] -> { :ok, { :create, bucket }}
      ["GET", bucket, key] -> { :ok, { :get, bucket, key }}
      ["SET", bucket, key, value] -> { :ok, { :set, bucket, key, value }}
      ["DELETE", bucket, key] -> { :ok, { :delete, bucket, key }}
      _ -> { :error, :invalid_command }
    end
  end
end

