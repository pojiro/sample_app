defmodule SampleAppWeb.AuthTest do
  use SampleAppWeb.ConnCase, async: true

  alias SampleAppWeb.Auth

  describe "Not logged in" do
    setup %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> bypass_through(SampleAppWeb.Router, :browser)
        |> get(Routes.static_page_path(conn, :home))

      {:ok, %{conn: conn, user: user}}
    end

    test "plug Auth assigns current_user when not logged in", %{conn: conn} do
      refute get_session(conn, :user_id)
      refute conn.assigns.current_user
    end
  end

  describe "Login with session" do
    setup %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> bypass_through(SampleAppWeb.Router, :browser)
        |> get(Routes.static_page_path(conn, :home))
        |> Auth.login(user)
        |> Auth.call([])

      {:ok, %{conn: conn, user: user}}
    end

    test "plug Auth assigns current_user when logged in", %{conn: conn, user: user} do
      assert get_session(conn, :user_id) == user.id
      assert conn.assigns.current_user.id == user.id
    end

    test "logout", %{conn: conn} do
      conn = Auth.logout(conn)
      refute get_session(conn, :user_id)
    end
  end

  describe "Login with cookie" do
    setup %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> bypass_through(SampleAppWeb.Router, :browser)
        |> get(Routes.static_page_path(conn, :home))
        |> Auth.remember_user(user, "true")
        |> Auth.call([])

      {:ok, %{conn: conn, user: user}}
    end

    test "plug Auth assigns current_user when logged in", %{conn: conn, user: user} do
      refute get_session(conn, :user_id)
      assert conn.cookies["remember_token"]
      assert conn.cookies["user_id"]
      assert conn.assigns.current_user.id == user.id
    end

    test "forget_user", %{conn: conn, user: user} do
      conn = Auth.forget_user(conn, user)
      refute conn.cookies["remember_token"]
      refute conn.cookies["user_id"]
    end
  end
end
