defmodule SampleAppWeb.Auth do
  import Plug.Conn

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

  def current_user(conn) do
    user_id = get_session(conn, :user_id)

    if user_id do
      SampleApp.Accounts.get_user(user_id)
    end
  end

  def logged_in?(conn) do
    !!get_session(conn, :user_id)
  end
end
