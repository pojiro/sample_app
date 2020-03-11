defmodule SampleAppWebRelationshipControllerTest do
  use SampleAppWeb.ConnCase

  alias SampleApp.Accounts.Relationship
  alias SampleApp.Repo

  setup do
    user = activated_user_fixture(:michael)
    other = activated_user_fixture(:archer)
    {:ok, user: user, other: other}
  end

  describe "create" do
    test "should redirect for not logged in user", %{conn: conn, user: user, other: other} do
      conn =
        post(conn, Routes.relationship_path(conn, :create), %{
          follower_id: user.id,
          followed_id: other.id
        })

      assert redirected_to(conn, 302) == Routes.session_path(conn, :new)
    end

    test "with valid attributes", %{conn: conn, user: user, other: other} do
      logged_in_conn = login(conn, user)

      conn =
        post(logged_in_conn, Routes.relationship_path(conn, :create), %{
          follower_id: user.id,
          followed_id: other.id
        })

      assert redirected_to(conn, 302) == Routes.user_path(conn, :show, other.id)
    end
  end

  describe "delete" do
    setup(%{conn: conn, user: user, other: other} = _params) do
      {:ok, relationship} =
        Relationship.changeset(%Relationship{}, %{follower_id: user.id, followed_id: other.id})
        |> Repo.insert()

      {:ok, conn: conn, user: user, other: other, relationship: relationship}
    end

    test "should redirect for not logged in user", %{
      conn: conn,
      user: _user,
      other: _other,
      relationship: relationship
    } do
      conn = delete(conn, Routes.relationship_path(conn, :delete, relationship))
      assert redirected_to(conn, 302) == Routes.session_path(conn, :new)
    end

    test "with valid attributes", %{
      conn: conn,
      user: user,
      other: other,
      relationship: relationship
    } do
      logged_in_conn = login(conn, user)
      conn = delete(logged_in_conn, Routes.relationship_path(conn, :delete, relationship))
      assert redirected_to(conn, 302) == Routes.user_path(conn, :show, other.id)
    end
  end
end
