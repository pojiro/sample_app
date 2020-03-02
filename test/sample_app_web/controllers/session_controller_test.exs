defmodule SampleAppWeb.SessionControllerTest do
  use SampleAppWeb.ConnCase

  alias SampleAppWeb.Auth

  setup do
    {:ok, user: activated_user_fixture(), deactivated_user: user_fixture(:archer)}
  end

  test "session_path :new", %{conn: conn} do
    conn = get(conn, Routes.session_path(conn, :new))
    assert html_response(conn, 200) =~ "Log in"
  end

  test "login with invalid information", %{conn: conn} do
    conn =
      post(conn, Routes.session_path(conn, :create), %{
        session: %{
          "email" => "",
          "password" => "",
          "remember_me" => "false"
        }
      })

    html = html_response(conn, 200)
    assert html =~ "Log in"
    assert html =~ "Invalid username/password combination"
  end

  test "login with valid information, not remember me", %{conn: conn, user: user} do
    conn = login(conn, user, "false")

    assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    conn = get(conn, Routes.static_page_path(conn, :home))
    assert Auth.logged_in?(conn)

    assert get_session(conn, :user_id) == user.id
    refute conn.cookies["remember_token"]

    assert get_flash(conn, :info) == "Welcome back!"
    html = html_response(conn, 200)
    refute html =~ "Log in"
    assert html =~ "Account"
    assert html =~ "Profile"
    assert html =~ "Settings"
    assert html =~ "Log out"
  end

  test "login with valid information, not remember me, followed by logout", %{
    conn: conn,
    user: user
  } do
    conn = login(conn, user, "false")

    conn = delete(conn, Routes.session_path(conn, :delete))
    assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    conn = get(conn, Routes.static_page_path(conn, :home))
    refute Auth.logged_in?(conn)

    refute get_session(conn, :user_id) == user.id
    refute conn.cookies["remember_token"]

    html = html_response(conn, 200)
    assert html =~ "Log in"
    refute html =~ "Account"
    refute html =~ "Profile"
    refute html =~ "Settings"
    refute html =~ "Log out"
  end

  test "login with valid information, remember me", %{conn: conn, user: user} do
    conn = login(conn, user, "true")

    assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    conn = get(conn, Routes.static_page_path(conn, :home))
    assert Auth.logged_in?(conn)

    assert get_session(conn, :user_id) == user.id
    assert conn.cookies["remember_token"]
    assert conn.cookies["user_id"]
  end

  test "login with valid information, remember me, followed by logout", %{conn: conn, user: user} do
    conn = login(conn, user, "true")

    conn = delete(conn, Routes.session_path(conn, :delete))
    assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    conn = get(conn, Routes.static_page_path(conn, :home))
    refute Auth.logged_in?(conn)

    refute get_session(conn, :user_id) == user.id
    refute conn.cookies["remember_token"]
    refute conn.cookies["user_id"]
  end

  test "login with deactivated user", %{conn: conn, deactivated_user: user} do
    conn = login(conn, user)
    assert get_flash(conn, :warning) =~ "Account not activated."
    assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
  end
end
