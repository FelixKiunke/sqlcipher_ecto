Sqlcipher.Ecto [![Build Status](https://travis-ci.org/FelixKiunke/sqlcipher_ecto.svg?branch=master "Build Status")](https://travis-ci.org/FelixKiunke/sqlcipher_ecto)
==============

Important Note
--------------
This is a fork of the 'regular' sqlite variant (sqlite_ecto). It is not finished yet and lots of things might change later on. Proceed with care :)

---

`Sqlcipher.Ecto` is a SQLCipher Adapter for Ecto.

Read [the tutorial](https://github.com/jazzyb/sqlite_ecto/wiki/Basic-Sqlite.Ecto-Tutorial)
for a detailed example of how to setup and use a SQLCipher repo with Ecto, or
just check-out the CliffsNotes in the sections below if you want to get
started quickly.

## Dependencies

`Sqlcipher.Ecto` relies on [Sqlcx](https://github.com/FelixKiunke/sqlcx) and
[esqlcipher](https://github.com/FelixKiunke/esqlcipher).  Since esqlcipher uses
Erlang NIFs, you will need a valid C compiler to build the library.

## Example

Here is an example usage:

```elixir
# In your config/config.exs file
config :my_app, Repo,
  adapter: Sqlcipher.Ecto,
  database: "ecto_simple.db",
  password: "password"        # this is optional!

# In your application code
defmodule Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Sqlcipher.Ecto
end

defmodule Weather do
  use Ecto.Model

  schema "weather" do
    field :city     # Defaults to type :string
    field :temp_lo, :integer
    field :temp_hi, :integer
    field :prcp,    :float, default: 0.0
  end
end

defmodule Simple do
  import Ecto.Query

  def sample_query do
    query = from w in Weather,
          where: w.prcp > 0 or is_nil(w.prcp),
         select: w
    Repo.all(query)
  end
end
```

## Usage

Add `Sqlcipher.Ecto` as a dependency in your `mix.exs` file.

```elixir
def deps do
  [{:sqlcipher_ecto, "~> 1.0.0"}]
end
```

You should also update your applications list to include both projects:
```elixir
def application do
  [applications: [:logger, :sqlcipher_ecto, :ecto]]
end
```

To use the adapter in your repo:
```elixir
defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Sqlcipher.Ecto
end
```

## Unsupported Ecto Constraints

The changeset functions
[`foreign_key_constraint/3`](http://hexdocs.pm/ecto/Ecto.Changeset.html#foreign_key_constraint/3)
and
[`unique_constraint/3`](http://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3)
are not supported by `Sqlcipher.Ecto` because the underlying SQLCipher database does
not provide enough information when such constraints are violated to support
the features.

Note that SQLCipher **does** support both unique and foreign key constraints via
[`unique_index/3`](http://hexdocs.pm/ecto/Ecto.Migration.html#unique_index/3)
and [`references/2`](http://hexdocs.pm/ecto/Ecto.Migration.html#references/2),
respectively.  When such constraints are violated, they will raise
`Sqlcipher.Ecto.Error` exceptions.

## Silently Ignored Options

There are a few Ecto options which `Sqlcipher.Ecto` silently ignores because
SQLite does not support them and raising an error on them does not make sense:
* Most column options will ignore `size`, `precision`, and `scale` constraints
  on types because SQLCipher columns have no types, and SQLCipher won't coerce
  any stored value.  Thus, all "strings" are `TEXT` and "numerics" will have
  arbitrary precision regardless of the declared column constraints.  The lone
  exception to this rule are Decimal types which accept `precision` and
  `scale` options because these constraints are handled in the driver
  software, not the SQLCipher database.
* If we are altering a table to add a `DATETIME` column with a `NOT NULL`
  constraint, SQLCipher will require a default value to be provided.  The only
  default value which would make sense in this situation is
  `CURRENT_TIMESTAMP`; however, when adding a column to a table, defaults must
  be constant values.  Therefore, in this situation the `NOT NULL` constraint
  will be ignored so that a default value does not need to be provided.
* When creating an index, `concurrently` and `using` values are silently
  ignored since they do not apply to SQLite.
