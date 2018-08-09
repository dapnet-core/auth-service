defmodule Auth.Router do
  use Plug.Router

  plug :match
  plug :dispatch


  forward "/auth/rabbitmq", to: Auth.RabbitMQ
  forward "/auth/users", to: Auth.Users
end
