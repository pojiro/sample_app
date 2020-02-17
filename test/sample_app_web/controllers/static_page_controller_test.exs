defmodule SampleAppWeb.StaticPageControllerTest do
  use SampleAppWeb.ConnCase

  @base_title "Phoenix Sample App"

  test "should get root", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Home | #{@base_title}"
  end

  test "should get home", %{conn: conn} do
    conn = get(conn, "/home")
    assert html_response(conn, 200) =~ "Home | #{@base_title}"
  end

  test "should get about", %{conn: conn} do
    conn = get(conn, "/about")
    assert html_response(conn, 200) =~ "About | #{@base_title}"
  end

  test "should get help", %{conn: conn} do
    conn = get(conn, "/help")
    assert html_response(conn, 200) =~ "Help | #{@base_title}"
  end

  test "should get contact", %{conn: conn} do
    conn = get(conn, "/contact")
    assert html_response(conn, 200) =~ "Contact | #{@base_title}"
  end
end
