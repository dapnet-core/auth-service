defmodule Auth.Users do
  use Plug.Router

  plug Auth.Plug.Api

  plug :match
  plug :dispatch

  get "/roles" do
    roles = Auth.Permissions.roles()
    send_resp(conn, 200, Poison.encode!(roles))
  end

  post "/login" do
    {user, conn} = login(conn)

    if user do
      roles = Map.get(user, "roles")
      permissions = Auth.Permissions.all(roles)

      response = %{
        user: user,
        permissions: permissions
      }

      send_resp(conn, 200, Poison.encode!(response))
    else
      send_resp(conn, 403, "Forbidden")
    end
  end

  post "/permission/:action" do
    permission(conn, action, nil)
  end

  post "/permission/:action/:id" do
    permission(conn, action, id)
  end

  defp permission(conn, action, id) do
    {user, conn} = login(conn)

    roles = if user do
      Map.get(user, "roles", ["user"])
    else
      ["guest"]
    end

    permission = Auth.Permissions.query(roles, action)

    response = case permission do
      :if_owner -> %{
                   access: id && Map.get(user, "_id") == id,
                   authenticated: user != nil,
                   roles: roles
               }
      :limited -> %{
                  access: permission != :none,
                  authenticated: user != nil,
                  roles: roles,
                  limited_to: ["_id"]
              }
      _ -> %{
           access: permission != :none,
           roles: roles,
           authenticated: user != nil
       }
    end

    send_resp(conn, 200, Poison.encode!(response))
  end

  defp login(conn) do
    {:ok, body, conn} = read_body(conn)
    case Poison.decode(body) do
      {:ok, params} ->
        user = Map.get(params, "username")
        pass = Map.get(params, "password")

        db = Auth.CouchDB.db("users")
        case CouchDB.Database.get(db, user) do
          {:ok, result} ->
            user = result |> Poison.decode!
            {hash, user} = user |> Map.pop("password")

            if hash && Comeonin.Bcrypt.checkpw(pass, hash) do
              {user, conn}
            else
              {nil, conn}
            end
          _ ->
            {nil, conn}
        end
      _ ->
        {nil, conn}
    end
  end
end
