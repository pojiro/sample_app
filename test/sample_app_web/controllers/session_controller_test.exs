defmodule SampleAppWeb.SessionControllerTest do
  use SampleAppWeb.ConnCase

  alias SampleAppWeb.Auth

  test "login with invalid information", %{conn: conn} do
    conn = get(conn, Routes.session_path(conn, :new))
    assert html_response(conn, 200) =~ "Log in"
    conn = post(conn, Routes.session_path(conn, :create), %{session: %{email: "", password: ""}})
    html = html_response(conn, 200)
    assert html =~ "Log in"
    assert html =~ "Invalid username/password combination"
  end

  test "login with valid information followed by logout", %{conn: conn} do
    user = user_fixture()

    conn = get(conn, Routes.session_path(conn, :new))
    assert html_response(conn, 200) =~ "Log in"

    conn =
      post(conn, Routes.session_path(conn, :create), %{
        session: %{email: user.email, password: user.password}
      })

    assert Auth.logged_in?(conn)
    assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    assert get_flash(conn, :info) == "Welcome back!"
    conn = get(conn, Routes.static_page_path(conn, :home))
    html = html_response(conn, 200)
    refute html =~ "Log in"
    assert html =~ "Profile"
    assert html =~ "Settings"
    assert html =~ "Log out"

    conn = delete(conn, Routes.session_path(conn, :delete))
    refute Auth.logged_in?(conn)

    assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    conn = get(conn, Routes.static_page_path(conn, :home))
    html = html_response(conn, 200)
    assert html =~ "Log in"
    refute html =~ "Profile"
    refute html =~ "Settings"
    refute html =~ "Log out"
  end
end
