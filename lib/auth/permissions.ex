defmodule Auth.Permissions do
  def roles do
    ["admin", "user", "support"]
  end

  def get("admin") do
    %{
      "user.list" => :all,
      "user.read" => :all,
      "user.create" => :all,
      "user.update" => :all,
      "user.delete" => :all,
      "user.change_role" => :all,

      "transmitter.list" => :all,
      "transmitter.read" => :all,
      "transmitter.create" => :all,
      "transmitter.update" => :all,
      "transmitter.delete" => :all,
      "transmitter_groups.list" => :all,

      "subscriber.list" => :all,
      "subscriber.read" => :all,
      "subscriber.create" => :all,
      "subscriber.update" => :all,
      "subscriber.delete" => :all,
      "subscriber_groups.list" => :all,

      "node.list" => :all,
      "node.read" => :all,
      "node.create" => :all,
      "node.update" => :all,
      "node.delete" => :all,

      "rubric.list" => :all,
      "rubric.read" => :all,
      "rubric.create" => :all,
      "rubric.update" => :all,
      "rubric.delete" => :all,

      "news.read" => :all,
      "news.create" => :all,
      "news.update" => :all,
      "news.delete" => :all,
    }
  end

  def get("suppport") do
    %{
      "user.list" => :all,
      "user.read" => :all,
      "user.create" => :all,
      "user.update" => :all,
      "user.delete" => :all,

      "transmitter.list" => :all,
      "transmitter.read" => :all,
      "transmitter.create" => :all,
      "transmitter.update" => :all,
      "transmitter.delete" => :all,
      "transmitter_groups.list" => :all,

      "subscriber.list" => :all,
      "subscriber.read" => :all,
      "subscriber.create" => :all,
      "subscriber.update" => :all,
      "subscriber.delete" => :all,
      "subscriber_groups.list" => :all,

      "node.list" => :all,
      "node.read" => :all,

      "rubric.list" => :all,
      "rubric.read" => :all,
      "rubric.create" => :all,
      "rubric.update" => :all,
      "rubric.delete" => :all,

      "news.read" => :all,
      "news.create" => :all,
      "news.update" => :all,
      "news.delete" => :all,
    }
  end

  def get("user") do
    %{
      "user.list" => :all,
      "user.read" => :if_owner,
      "user.update" => :if_owner,
      "user.delete" => :if_owner,

      "transmitter.list" => :all,
      "transmitter.read" => :if_owner,
      "transmitter.update" => :if_owner,
      "transmitter.delete" => :if_owner,
      "transmitter_groups.list" => :all,

      "subscriber.list" => :all,
      "subscriber.read" => :if_owner,
      "subscriber.update" => :if_owner,
      "subscriber.delete" => :if_owner,

      "node.list" => :all,
      "node.read" => :all,

      "rubric.list" => :all,
      "rubric.read" => :all,

      "news.read" => :all,
      "news.create" => :if_owner,
      "news.update" => :if_owner,
      "news.delete" => :if_owner,
    }
  end

  def get("guest") do
    %{
      "transmitter.list" => :limited,
    }
  end

  def get(_) do
    %{}
  end

  def query(roles, action) do
    Enum.reduce roles, :none, fn role, perm ->
      role_perm = Map.get(get(role), action, :none)
      case {perm, role_perm} do
        {:all, _} -> :all
        {_, :all} -> :all
        {:none, :if_owner} -> :if_owner
        {:limited, :if_owner} -> :if_owner
        {:none, :limited} -> :limited
        _ -> perm
      end
    end
  end
end
