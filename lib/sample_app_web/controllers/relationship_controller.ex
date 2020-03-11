defmodule SampleAppWeb.RelationshipController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  plug :logged_in_user when action in [:create, :delete]

  def create(conn, %{"follower_id" => follower_id, "followed_id" => followed_id} = _params) do
    {:ok, _} = Accounts.create_relationship(%{follower_id: follower_id, followed_id: followed_id})

    redirect(conn, to: Routes.user_path(conn, :show, followed_id))
  end

  def delete(conn, %{"id" => id} = _params) do
    relationship = Accounts.get_relationship!(id)
    {:ok, _} = Accounts.delete_relationship(relationship)

    redirect(conn, to: Routes.user_path(conn, :show, relationship.followed_id))
  end
end
