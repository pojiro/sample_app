defmodule SampleAppWeb.StaticPageController do
  use SampleAppWeb, :controller

  def home(conn, _params) do
    render(conn, "home.html")
  end

  def about(conn, _params) do
    render(conn, "about.html", page_title: "About")
  end

  def help(conn, _params) do
    render(conn, "help.html", page_title: "Help")
  end

  def contact(conn, _params) do
    render(conn, "contact.html", page_title: "Contact")
  end
end
