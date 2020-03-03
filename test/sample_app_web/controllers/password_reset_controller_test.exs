defmodule SampleAppWeb.PasswordResetControllerTest do
  use SampleAppWeb.ConnCase

  alias SampleApp.Accounts

  setup do
    {:ok, user: activated_user_fixture()}
  end

  test "new action with valid email", %{conn: conn} do
    conn = get(conn, Routes.password_reset_path(conn, :new))
    assert html_response(conn, 200) =~ "Forgot password"
  end

  test "create action with valid email", %{conn: conn, user: user} do
    conn = post(conn, Routes.password_reset_path(conn, :create), %{email: user.email})
    assert redirected_to(conn, 302) == Routes.static_page_path(conn, :home)
    assert get_flash(conn, :info) == "Email sent with password reset instructions"
  end

  test "create action with invalid email", %{conn: conn} do
    conn = post(conn, Routes.password_reset_path(conn, :create), %{email: ""})
    assert html_response(conn, 200) =~ "Forgot password"
    assert get_flash(conn, :warning) == "Email address not found"
  end

  test "edit action", %{conn: conn, user: user} do
    {conn, _user} = password_reset(conn, user)
    assert html_response(conn, 200) =~ "Reset password"
  end

  test "update action with valid information", %{conn: conn, user: user} do
    {conn, user} = password_reset(conn, user)

    conn =
      put(conn, Routes.password_reset_path(conn, :update, user.password_reset_token),
        email: user.email,
        user: %{password: "new password", password_confirmation: "new password"}
      )

    user = Accounts.get_user!(user.id)
    assert user.password_reset_hash == nil

    assert get_flash(conn, :info) == "Password has been reset."
    assert redirected_to(conn, 302) == Routes.user_path(conn, :show, user)
  end

  test "update action with invalid information", %{conn: conn, user: user} do
    {conn, user} = password_reset(conn, user)

    conn =
      put(conn, Routes.password_reset_path(conn, :update, user.password_reset_token),
        email: user.email,
        user: %{password: "", password_confirmation: ""}
      )

    assert html_response(conn, 200) =~ "Reset password"
  end

  defp password_reset(conn, user) do
    {:ok, user} = Accounts.password_reset(user)

    conn =
      get(
        conn,
        Routes.password_reset_path(conn, :edit, user.password_reset_token, email: user.email)
      )

    {conn, user}
  end
end
