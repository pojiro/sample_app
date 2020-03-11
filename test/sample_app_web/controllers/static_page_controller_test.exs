defmodule SampleAppWeb.StaticPageControllerTest do
  use SampleAppWeb.ConnCase

  alias SampleApp.Accounts

  @base_title "Phoenix Sample App"

  test "should get root", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "<title>#{@base_title}"
  end

  test "should get home", %{conn: conn} do
    conn = get(conn, "/home")
    assert html_response(conn, 200) =~ "<title>#{@base_title}"
  end

  test "should get about", %{conn: conn} do
    conn = get(conn, "/about")
    assert html_response(conn, 200) =~ "<title>About | #{@base_title}"
  end

  test "should get help", %{conn: conn} do
    conn = get(conn, "/help")
    assert html_response(conn, 200) =~ "<title>Help | #{@base_title}"
  end

  test "should get contact", %{conn: conn} do
    conn = get(conn, "/contact")
    assert html_response(conn, 200) =~ "<title>Contact | #{@base_title}"
  end

  describe "logged in user's home" do
    setup do
      michael = activated_user_fixture(:michael)
      archer = activated_user_fixture(:archer)
      admin = activated_admin_user_fixture()

      {:ok, user: michael, michael: michael, archer: archer, admin: admin}
    end

    test "should get feed", %{conn: conn, user: user} do
      logged_in_conn = login(conn, user)
      conn = get(logged_in_conn, "/home")
      assert html_response(conn, 200) =~ "Micropost Feed"
    end

    test "feed should have the right posts", %{
      conn: conn,
      michael: michael,
      archer: archer,
      admin: admin
    } do
      Enum.each([michael, archer, admin], fn user ->
        Enum.each(1..5, fn _ ->
          SampleApp.Multimedia.create_micropost(%{
            content: Faker.Lorem.sentence(5),
            user_id: user.id
          })
        end)
      end)

      Accounts.create_relationship(%{follower_id: michael.id, followed_id: archer.id})

      logged_in_conn = login(conn, michael)
      conn = get(logged_in_conn, "/home")
      parsed_html = Floki.parse_document!(html_response(conn, 200))

      assert Floki.find(parsed_html, "section.user_info span:last-child")
             |> Floki.text() == "5 micropost(s)"

      assert Floki.find(parsed_html, ".microposts a[href=\"/users/#{michael.id}\"] img")
             |> Enum.count() == 5

      assert Floki.find(parsed_html, ".microposts a[href=\"/users/#{archer.id}\"] img")
             |> Enum.count() == 5

      assert Floki.find(parsed_html, ".microposts a[href=\"/users/#{admin.id}\"] img")
             |> Enum.count() == 0
    end
  end
end
