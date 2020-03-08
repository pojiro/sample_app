defmodule SampleAppWeb.UserControllerTest do
  use SampleAppWeb.ConnCase

  alias SampleApp.Accounts
  alias SampleAppWeb.Auth

  @create_attrs user_attrs()
  # @update_attrs %{email: "some updated email", name: "some updated name"}
  @invalid_attrs user_attrs(%{email: "", name: ""})

  # def fixture(:user) do
  #  {:ok, user} = Accounts.create_user(@create_attrs)
  #  user
  # end

  describe "index" do
    setup [:create_user]

    test "lists all users", %{conn: conn, user: user} do
      logged_in_conn = login(conn, user)
      conn = get(logged_in_conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "All Users"
    end

    test "should redirect index when not logged in", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert redirected_to(conn, 302) == Routes.session_path(conn, :new)
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign up"
    end
  end

  describe "show" do
    setup [:create_user]

    test "user has 20 microposts", %{conn: conn, user: user} do
      Enum.each(1..20, fn _ ->
        SampleApp.Multimedia.create_micropost(%{
          content: Faker.Lorem.sentence(5),
          user_id: user.id
        })
      end)

      logged_in_conn = login(conn, user)
      conn = get(logged_in_conn, Routes.user_path(conn, :show, user))

      parsed_html = Floki.parse_document!(html_response(conn, 200))
      assert Floki.find(parsed_html, "h1") |> Floki.text() =~ user.name
      assert Floki.find(parsed_html, "h1 img.gravatar")
      assert Floki.find(parsed_html, "ol.microposts li") |> Enum.count() == 20
      assert Floki.find(parsed_html, "ul.pagination li.active") |> Floki.text() == "1"
    end

    test "should redirect show when not logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert redirected_to(conn, 302) == Routes.session_path(conn, :new)
    end
  end

  describe "create user, sign up" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert redirected_to(conn) == Routes.static_page_path(conn, :home)
      assert get_flash(conn, :info) == "Please check your email to activate your account."
      refute Auth.logged_in?(conn)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      html = html_response(conn, 200)
      assert html =~ "Sign up"
      assert html =~ "<p class=\"alert alert-danger"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      logged_in_conn = login(conn, user)
      conn = get(logged_in_conn, Routes.user_path(conn, :edit, user))

      assert html_response(conn, 200) =~ "Update your profile"
    end

    test "should redirect when not logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))

      assert redirected_to(conn, 302) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) == "Please log in."
    end

    test "should redirect when logged in as wrong user", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      logged_in_conn = login(conn, other_user)
      conn = get(logged_in_conn, Routes.user_path(conn, :edit, user))

      assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    end
  end

  describe "update user" do
    setup [:create_user]

    test "invalid information", %{conn: conn, user: user} do
      logged_in_conn = login(conn, user)

      conn =
        put(logged_in_conn, Routes.user_path(conn, :update, user), %{
          "user" => %{
            name: "",
            email: "foo@invalid",
            password: "foo",
            password_confirmation: "bar"
          }
        })

      assert html_response(conn, 200) =~ "Update your profile"
    end

    test "valid information", %{conn: conn, user: user} do
      logged_in_conn = login(conn, user)

      conn =
        put(logged_in_conn, Routes.user_path(conn, :update, user), %{
          "user" => %{
            name: "Foo bar",
            email: "foo@bar.com",
            password: "",
            password_confirmation: ""
          }
        })

      assert redirected_to(conn, 302) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :info) == "User updated successfully."
    end

    test "should redirect when not logged in", %{conn: conn, user: user} do
      conn =
        put(conn, Routes.user_path(conn, :update, user), %{
          "user" => %{
            name: "Foo bar",
            email: "foo@bar.com",
            password: "",
            password_confirmation: ""
          }
        })

      assert redirected_to(conn, 302) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) == "Please log in."
    end

    test "should redirect when logged in as wrong user", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      logged_in_conn = login(conn, other_user)

      conn =
        put(logged_in_conn, Routes.user_path(conn, :update, user), %{
          "user" => %{
            name: "Foo bar",
            email: "foo@bar.com",
            password: "",
            password_confirmation: ""
          }
        })

      assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    end

    test "should not allow the admin attribute to be update via the web", %{
      conn: conn,
      user: user
    } do
      refute user.admin
      logged_in_conn = login(conn, user)

      put(logged_in_conn, Routes.user_path(conn, :update, user), %{
        "user" => %{
          password: "",
          password_confirmation: "",
          admin: true
        }
      })

      refute Accounts.get_user!(user.id).admin
    end
  end

  describe "friendly forwarding" do
    setup [:create_user]

    test "successful edit", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      logged_in_conn = login(conn, user)
      assert redirected_to(logged_in_conn, 302) == Routes.user_path(conn, :edit, user)

      conn =
        put(logged_in_conn, Routes.user_path(conn, :update, user), %{
          "user" => %{
            name: "Foo bar",
            email: "foo@bar.com",
            password: "",
            password_confirmation: ""
          }
        })

      assert redirected_to(conn, 302) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :info) == "User updated successfully."
    end
  end

  describe "delete" do
    setup [:create_user]

    test "successful delete", %{conn: conn, admin_user: admin_user, user: user} do
      logged_in_conn = login(conn, admin_user)

      conn = delete(logged_in_conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn, 302) == Routes.user_path(conn, :index)

      assert_error_sent 404, fn ->
        get(logged_in_conn, Routes.user_path(conn, :show, user))
      end
    end

    test "should redirect destroy when not logged in", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn, 302) == Routes.session_path(conn, :new)
    end

    test "should redirect delete when logged in as a non-admin", %{conn: conn, user: user} do
      logged_in_conn = login(conn, user)
      conn = delete(logged_in_conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    end
  end

  defp create_user(_) do
    user = activated_user_fixture(user_attrs(:michael))

    {
      :ok,
      user: user,
      other_user: activated_user_fixture(user_attrs(:archer)),
      admin_user: activated_admin_user_fixture()
    }
  end
end
