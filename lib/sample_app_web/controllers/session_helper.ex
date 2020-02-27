defmodule SampleAppWeb.SessionHelper do
  import Plug.Conn
  import Phoenix.Controller

  def store_location(conn) do
    put_session(conn, "forwarding_path", conn.request_path)
  end

  def redirect_back_or(conn, default) do
    path = get_session(conn, "forwarding_path") || default

    conn
    |> delete_resp_cookie("forwarding_path")
    |> redirect(to: path)
  end
end
