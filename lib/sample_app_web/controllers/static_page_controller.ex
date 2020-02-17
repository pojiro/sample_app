defmodule SampleAppWeb.StaticPageController do
  use SampleAppWeb, :controller

  def home(conn, _params) do
    render(conn, "home.html")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def help(conn, _params) do
    render(conn, "help.html")
  end
end
