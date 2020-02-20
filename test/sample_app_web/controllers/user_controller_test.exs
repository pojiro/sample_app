defmodule SampleAppWeb.UserControllerTest do
  use SampleAppWeb.ConnCase

  # alias SampleApp.Accounts
  alias SampleAppWeb.Auth

  @create_attrs user_attrs()
  # @update_attrs %{email: "some updated email", name: "some updated name"}
  @invalid_attrs user_attrs(%{email: "", name: ""})

  # def fixture(:user) do
  #  {:ok, user} = Accounts.create_user(@create_attrs)
  #  user
  # end

  # describe "index" do
  #  test "lists all users", %{conn: conn} do
  #    conn = get(conn, Routes.user_path(conn, :index))
  #    assert html_response(conn, 200) =~ "Listing Users"
  #  end
  # end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign up"
    end
  end

  describe "create user, sign up" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      html = html_response(conn, 200)
      assert html =~ "Welcome to the Sample App!"
      assert html =~ "<p class=\"alert alert-success"
      assert Auth.logged_in?(conn)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      html = html_response(conn, 200)
      assert html =~ "Sign up"
      assert html =~ "<p class=\"alert alert-danger"
    end
  end

  # describe "edit user" do
  #  setup [:create_user]

  #  test "renders form for editing chosen user", %{conn: conn, user: user} do
  #    conn = get(conn, Routes.user_path(conn, :edit, user))
  #    assert html_response(conn, 200) =~ "Edit User"
  #  end
  # end

  # describe "update user" do
  #  setup [:create_user]

  #  test "redirects when data is valid", %{conn: conn, user: user} do
  #    conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
  #    assert redirected_to(conn) == Routes.user_path(conn, :show, user)

  #    conn = get(conn, Routes.user_path(conn, :show, user))
  #    assert html_response(conn, 200) =~ "some updated email"
  #  end

  #  test "renders errors when data is invalid", %{conn: conn, user: user} do
  #    conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
  #    assert html_response(conn, 200) =~ "Edit User"
  #  end
  # end

  # describe "delete user" do
  #  setup [:create_user]

  #  test "deletes chosen user", %{conn: conn, user: user} do
  #    conn = delete(conn, Routes.user_path(conn, :delete, user))
  #    assert redirected_to(conn) == Routes.user_path(conn, :index)
  #    assert_error_sent 404, fn ->
  #      get(conn, Routes.user_path(conn, :show, user))
  #    end
  #  end
  # end

  # defp create_user(_) do
  #  user = fixture(:user)
  #  {:ok, user: user}
  # end
end
