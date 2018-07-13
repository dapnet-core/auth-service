defmodule Auth.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/auth/rabbitmq/user" do
    conn = fetch_query_params(conn)

    user = Map.get(conn.params, "username")
    pass = Map.get(conn.params, "password")

    case user do
      "node-" <> node_id ->
        db = Auth.CouchDB.db("nodes")
        case CouchDB.Database.get(db, node_id) do
        {:ok, result} ->
          auth_key = result |> Poison.decode! |> Map.get("auth_key")
          if pass == auth_key do
            send_resp(conn, 200, "allow administrator")
          else
            send_resp(conn, 200, "deny")
          end
          _ ->
            send_resp(conn, 200, "deny")
        end

      "tx-" <> tx_id ->
        db = Auth.CouchDB.db("transmitters")

        case CouchDB.Database.get(db, tx_id) do
          {:ok, result} ->
            auth_key = result |> Poison.decode! |> Map.get("auth_key")
            if pass == auth_key do
              send_resp(conn, 200, "allow")
            else
              send_resp(conn, 200, "deny")
            end
          _ ->
            send_resp(conn, 200, "deny")
        end

     _ -> send_resp(conn, 200, "deny")
    end
  end

  get "/auth/rabbitmq/vhost" do
    conn = fetch_query_params(conn)
    user = Map.get(conn.params, "username")

    case user do
      "node-" <> node_id -> send_resp(conn, 200, "allow")
      _ -> send_resp(conn, 200, "allow")
    end
  end

  get "/auth/rabbitmq/resource" do
    conn = fetch_query_params(conn)
    user = Map.get(conn.params, "username")

    case user do
      "node-" <> node_id -> send_resp(conn, 200, "allow")
      _ -> send_resp(conn, 200, "allow")
    end

  end

  get "/auth/rabbitmq/topic" do
    conn = fetch_query_params(conn)
    user = Map.get(conn.params, "username")

    case user do
      "node-" <> node_id -> send_resp(conn, 200, "allow")
      _ -> send_resp(conn, 200, "allow")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
