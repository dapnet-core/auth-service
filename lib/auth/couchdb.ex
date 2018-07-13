defmodule Auth.CouchDB do
  use GenServer
  require Logger

  def db(name), do: GenServer.call(__MODULE__, {:db, name})
  def auth({:user, user, password}), do: GenServer.call(__MODULE__, {:auth_user, user, password})
  def auth({:node, node, auth_key}), do: GenServer.call(__MODULE__, {:auth_node, node, auth_key})

  def start_link() do
    GenServer.start_link(__MODULE__, {}, [name: __MODULE__])
  end

  def init(args) do
    user = System.get_env("COUCHDB_USER")
    pass = System.get_env("COUCHDB_PASSWORD")
    server = CouchDB.connect("couchdb", 5984, "http", user, pass)
    {:ok, server}
  end

  def handle_call({:db, name}, _from, server) do
    {:reply, CouchDB.Server.database(server, name), server}
  end

  def handle_call({:auth_node, name, auth_key}, _from, server) do
    case get_node(name, server) do
      {:ok, node} ->
        IO.inspect node
        if auth_key == Map.get(node, "auth_key") do
          {:reply, true, server}
        else
          {:reply, false, server}
        end
      _ ->
        IO.inspect "failed to get node #{name}"
        {:reply, false, server}
    end
  end

  def handle_call({:auth_user, name, password}, _from, server) do
    case get_user(name, server) do
      {:ok, user} ->
        if check_password(password, Map.get(user, "password")) do
          {:reply, true, server}
        else
          {:reply, false, server}
        end
      _ ->
        {:reply, false, server}
    end
  end

  defp check_password(password, hash) do
    Comeonin.Bcrypt.checkpw(password, hash)
  end

  defp get_node(name, server) do
    db = server |> CouchDB.Server.database("nodes")
    result = CouchDB.Database.get(db, String.downcase(name))

    case result do
      {:ok, data} ->
        Poison.decode(data)
      _ ->
        {:error, :not_found}
    end
  end

  defp get_user(name, server) do
    db = server |> CouchDB.Server.database("users")
    result = CouchDB.Database.get(db, String.downcase(name))

    case result do
      {:ok, data} ->
        Poison.decode(data)
      _ ->
        {:error, :not_found}
    end
  end
end
