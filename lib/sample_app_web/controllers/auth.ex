defmodule SampleAppWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias SampleAppWeb.Router.Helpers, as: Routes
  alias SampleAppWeb.SessionHelper

  @max_age {:max_age, 20 * 365 * 24 * 60 * 60}
  @remember_token_salt "remember me"
  @remember_token_key "remember_token"
  @user_id_key "user_id"

  def init(opts), do: opts

  def call(conn, _opts) do
    cond do
      user_id = get_session(conn, :user_id) ->
        user = SampleApp.Accounts.get_user!(user_id)
        assign(conn, :current_user, user)

      signed_user_id = conn.cookies[@user_id_key] ->
        {:ok, user_id} =
          Phoenix.Token.verify(conn, @remember_token_salt, signed_user_id, [@max_age])

        user = SampleApp.Accounts.get_user!(user_id)

        case SampleApp.Accounts.authenticate_user(user,
               remember_token: conn.cookies[@remember_token_key]
             ) do
          {:ok, user} ->
            assign(conn, :current_user, user)

          {:error, _reason} ->
            assign(conn, :current_user, nil)
        end

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> clear_session()
    # drop the whole session at the end of request
    |> configure_session(drop: true)
  end

  def remember_user(conn, user, "true") do
    token = SampleApp.Helper.random_string()
    signed_user_id = Phoenix.Token.sign(conn, @remember_token_salt, user.id)

    {:ok, user} = SampleApp.Accounts.remember_user(user, %{remember_token: token})

    conn
    |> put_resp_cookie(@remember_token_key, user.remember_token, [@max_age])
    |> put_resp_cookie(@user_id_key, signed_user_id, [@max_age])
  end

  def remember_user(conn, user, "false") do
    {:ok, _user} = SampleApp.Accounts.remember_user(user, %{remember_token: nil})

    conn
    |> delete_resp_cookie(@remember_token_key, [@max_age])
    |> delete_resp_cookie(@user_id_key, [@max_age])
  end

  def forget_user(conn, user), do: remember_user(conn, user, "false")

  def logged_in?(conn), do: conn.assigns.current_user

  def logged_in_user(conn, _opts) do
    if logged_in?(conn) do
      conn
    else
      conn
      |> SessionHelper.store_location()
      |> put_flash(:error, "Please log in.")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  def correct_user(%{assigns: %{current_user: login_user}} = conn, _opts) do
    user = SampleApp.Accounts.get_user!(conn.params["id"])

    if login_user.id == user.id do
      conn
    else
      conn
      |> redirect(to: Routes.static_page_path(conn, :home))
      |> halt()
    end
  end

  def admin_user(%{assigns: %{current_user: login_user}} = conn, _opts) do
    if login_user.admin do
      conn
    else
      conn
      |> redirect(to: Routes.static_page_path(conn, :home))
      |> halt()
    end
  end
end
