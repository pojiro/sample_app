defmodule SampleAppWeb.SessionHelper do
  import Plug.Conn
  import Phoenix.Controller

  def store_location(conn) do
    put_session(conn, "forwarding_path", conn.request_path)
  end

  def redirect_back_or(conn, default) do
    path = get_session(conn, "forwarding_path") || default
    delete_session(conn, "forwarding_path")
    redirect(conn, to: path)
  end
end
