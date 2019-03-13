# Envconfig

Describe all the environment variables available for the project in one place. It defines helper functions to access the
value and cast them to the correct type.

The goal is to replace this kind of code:

```elixir
# lib/my_app/application.ex
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Management.Router, options: [port: http_port()]),
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp http_port do
    "MYAPP_HTTP_PORT"
    |> System.get_env()
    |> String.to_integer()
  end
end

# lib/my_app/repo.ex
defmodule MyApp.Repo do
  use Ecto.Repo, otp_app: :my_app

  def init(_type, config) do
    new_config =
      config
      |> Keyword.put(:database, database_name())
      |> Keyword.put(:username, System.get_env("MYAPP_SQL_USERNAME"))
      |> Keyword.put(:password, System.get_env("MYAPP_SQL_PASSWORD"))
      |> Keyword.put(:hostname, System.get_env("MYAPP_SQL_HOSTNAME"))
      |> Keyword.put(:port, System.get_env("MYAPP_SQL_PORT"))

    {:ok, new_config}
  end

  defp database_name do
    System.get_env("MYAPP_SQL_DATABASE") || "myapp_#{Mix.env()}"
  end
end
```

The problems with this code:

1. it clutters the source code by dealing with details of how to read environment variables and cast them
2. we have multiple places where we read environment variables so it's hard to know what's needed for the application


## Solution

```elixir
# lib/my_app/configuration.ex
defmodule MyApp.Configuration do
  use Envconfig

  defenv(:http_port, "MYAPP_HTTP_PORT", :int)

  defenv(:sql_username, "MYAPP_SQL_USERNAME", :non_empty_string)
  defenv(:sql_password, "MYAPP_SQL_PASSWORD", :non_empty_string)
  defenv(:sql_hostname, "MYAPP_SQL_HOSTNAME", :non_empty_string)
  defenv(:sql_port, "MYAPP_SQL_PORT", :non_empty_string)
  defenv(:sql_database, "MYAPP_SQL_DATABASE", :non_empty_string)
end

# lib/my_app/application.ex
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Management.Router, options: [port: MyApp.Configuration.http_port!]),
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

# lib/my_app/repo.ex
defmodule MyApp.Repo do
  use Ecto.Repo, otp_app: :myapp

  def init(_type, config) do
    new_config =
      config
      |> Keyword.put(:database, database_name())
      |> Keyword.put(:username, MyApp.Configuration.sql_username!)
      |> Keyword.put(:password, MyApp.Configuration.sql_password!)
      |> Keyword.put(:hostname, MyApp.Configuration.sql_hostname!)
      |> Keyword.put(:port, MyApp.Configuration.sql_port!)

    {:ok, new_config}
  end

  defp database_name do
    case MyApp.Configuration.sql_database do
      {:ok, database} ->
        database
      {:error, _reason} ->
        "myapp_#{Mix.env()}"
    end
  end
end
```
