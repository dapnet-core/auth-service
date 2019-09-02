defmodule Auth.RabbitMQ do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/user" do
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

      "thirdparty-" <> user ->
        db = Auth.CouchDB.db("users")

        case CouchDB.Database.get(db, user) do
          {:ok, result} ->
            user = result |> Poison.decode!
            {hash, user} = user |> Map.pop("password")

            if hash && Comeonin.Bcrypt.checkpw(pass, hash) do
              is_thirdparty = Map.get(user, "roles", [])
              |> Enum.any?(fn role -> String.starts_with?(role, "thirdparty.") end)

              if is_thirdparty do
                send_resp(conn, 200, "allow")
              else
                send_resp(conn, 200, "deny")
              end
            else
              send_resp(conn, 200, "deny")
            end
          _ ->
            send_resp(conn, 200, "deny")
        end

     _ -> send_resp(conn, 200, "deny")
    end
  end

  get "/vhost" do
    conn = fetch_query_params(conn)
    user = Map.get(conn.params, "username")

    case user do
      "node-" <> node_id -> send_resp(conn, 200, "allow")
      _ -> send_resp(conn, 200, "allow")
    end
  end

  get "/resource" do
    conn = fetch_query_params(conn)
    user = Map.get(conn.params, "username")

    case user do
      "node-" <> node_id -> send_resp(conn, 200, "allow")
      _ -> send_resp(conn, 200, "allow")
    end

  end

  get "/topic" do
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
