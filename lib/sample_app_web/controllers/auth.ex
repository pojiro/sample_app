defmodule SampleAppWeb.Auth do
  import Plug.Conn

  @max_age {:max_age, 20 * 365 * 24 * 60 * 60}
  @remember_token_salt "remember me"
  @remember_token_key "remember_token"
  @user_id_key "user_id"

  def init(opts), do: opts

  def call(conn, _opts) do
    cond do
      user_id = get_session(conn, :user_id) ->
        user = SampleApp.Accounts.get_user(user_id)
        assign(conn, :current_user, user)

      signed_user_id = conn.cookies[@user_id_key] ->
        {:ok, user_id} =
          Phoenix.Token.verify(conn, @remember_token_salt, signed_user_id, [@max_age])

        user = SampleApp.Accounts.get_user(user_id)

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
    token = generate_onetime_token()
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

  defp generate_onetime_token(length \\ 64) do
    # see https://github.com/phoenixframework/phoenix/blob/master/lib/mix/tasks/phx.gen.secret.ex
    # literal copy of mix phx.gen.secret implementation.
    :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
  end
end
