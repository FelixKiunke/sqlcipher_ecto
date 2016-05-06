defmodule Sqlcipher.Ecto do
  @moduledoc ~S"""
  Ecto Adapter module for SQLCipher.

  It uses Sqlcx and Esqlcipher for accessing the SQLSipher database.

  ## Features

  ## Options

  There are a limited number of options available because SQLite/SQLCipher is so simple to use.

  ### Compile time options

  These options should be set in the config file and require recompilation in
  order to make an effect.

    * `:adapter` - The adapter name, in this case, `Sqlcipher.Ecto`
    * `:timeout` - The default timeout to use on queries, defaults to `5000`

  ### Connection options

    * `:database` - This option can take the form of a path to the SQLCipher
      database file or `":memory:"` for an in-memory database.  See the
      [SQLite docs](https://sqlite.org/uri.html) for more options such as
      shared memory caches.

  """

  import Sqlcipher.Ecto.Util, only: [json_library: 0]

  # Inherit all behaviour from Ecto.Adapters.SQL
  use Ecto.Adapters.SQL, :sqlcx

  # And provide a custom storage implementation
  @behaviour Ecto.Adapter.Storage

  ## Custom SQLite Types

  def load({:embed, _} = type, binary) when is_binary(binary) do
    super(type, json_library.decode!(binary))
  end
  def load(:map, binary) when is_binary(binary) do
    super(:map, json_library.decode!(binary))
  end
  def load(type, value), do: super(type, value)

  ## Storage API

  @doc false
  def storage_up(opts) do
    database = Keyword.get(opts, :database)
    if File.exists?(database) do
      {:error, :already_up}
    else
      database |> Path.dirname |> File.mkdir_p!
      case Sqlcx.open(database) do
        {:error, _msg} = err -> err
        {:ok, db} ->
          Sqlcx.close(db)
          :ok
      end
    end
  end

  @doc false
  def storage_down(opts) do
    database = Keyword.get(opts, :database)
    case File.rm(database) do
      {:error, :enoent} -> {:error, :already_down}
      result -> result
    end
  end

  @doc false
  def supports_ddl_transaction?, do: true
end
