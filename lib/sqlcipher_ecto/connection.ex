if Code.ensure_loaded?(Sqlcx.Server) do
  defmodule Sqlcipher.Ecto.Connection do
    @moduledoc false

    @behaviour Ecto.Adapters.SQL.Query

    # Connect to a new Sqlcx.Server.  Enable and verify the foreign key
    # constraints for the connection.
    def connect(opts) do
      {database, opts} = Keyword.pop(opts, :database)
      case Sqlcx.Server.start_link(database, opts) do
        {:ok, pid} ->
          :ok = Sqlcx.Server.exec(pid, "PRAGMA foreign_keys = ON")
          {:ok, [[foreign_keys: 1]]} = Sqlcx.Server.query(pid, "PRAGMA foreign_keys")
          {:ok, pid}
        error -> error
      end
    end

    def disconnect(pid) do
      Sqlcx.Server.stop(pid)
      :ok
    end

    defdelegate to_constraints(error), to: Sqlcipher.Ecto.Error

    ## Transaction

    alias Sqlcipher.Ecto.Transaction

    defdelegate begin_transaction, to: Transaction

    defdelegate rollback, to: Transaction

    defdelegate commit, to: Transaction

    defdelegate savepoint(name), to: Transaction

    defdelegate rollback_to_savepoint(name), to: Transaction

    ## Query

    alias Sqlcipher.Ecto.Query

    defdelegate query(pid, sql, params, opts), to: Query

    defdelegate all(query), to: Query

    defdelegate update_all(query), to: Query

    defdelegate delete_all(query), to: Query

    defdelegate insert(prefix, table, fields, returning), to: Query

    defdelegate update(prefix, table, fields, filters, returning), to: Query

    defdelegate delete(prefix, table, filters, returning), to: Query

    ## DDL

    alias Sqlcipher.Ecto.DDL

    defdelegate execute_ddl(ddl), to: DDL
  end
end
