defmodule SampleAppWeb.MicropostControllerTest do
  use SampleAppWeb.ConnCase, async: true

  setup do
    user = activated_user_fixture(:michael)
    other = activated_user_fixture(:archer)
    {:ok, user: user, other: other}
  end

  test "should redirect create when not logged in", %{conn: conn, user: user} do
    conn =
      post(conn, Routes.micropost_path(conn, :create), %{content: "Lorem ipsum", user_id: user.id})

    assert redirected_to(conn, 302) == Routes.session_path(conn, :new)
  end

  test "should redirect delete when not logged in", %{conn: conn, user: user} do
    micropost = micropost_fixture(user, :orange)

    conn = delete(conn, Routes.micropost_path(conn, :delete, micropost))
    assert redirected_to(conn, 302) == Routes.session_path(conn, :new)
  end

  test "should redirect delete for not owner micropost", %{conn: conn, user: user, other: other} do
    micropost = micropost_fixture(user, :orange)

    logged_in_conn = login(conn, other)
    conn = delete(logged_in_conn, Routes.micropost_path(conn, :delete, micropost))
    assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
  end

  test "should not represent delete link on other user profile", %{
    conn: conn,
    user: user,
    other: other
  } do
    micropost_fixture(user, :orange)
    micropost_fixture(other, :orange)

    logged_in_conn = login(conn, user)
    conn = get(logged_in_conn, Routes.user_path(conn, :show, user))
    parsed_html = Floki.parse_document!(html_response(conn, 200))

    assert parsed_html
           |> Floki.find("a[data-method=\"delete\"][data-to*=\"/micropost\"]")
           |> Floki.text() == "delete"

    conn = get(logged_in_conn, Routes.user_path(conn, :show, other))
    parsed_html = Floki.parse_document!(html_response(conn, 200))

    refute parsed_html
           |> Floki.find("a[data-method=\"delete\"][data-to*=\"/micropost\"]")
           |> Floki.text() == "delete"
  end
end
