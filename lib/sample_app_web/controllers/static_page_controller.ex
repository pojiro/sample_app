defmodule SampleAppWeb.StaticPageController do
  use SampleAppWeb, :controller

  alias SampleApp.Accounts
  alias SampleApp.{Multimedia, Multimedia.Micropost}

  def home(conn, params) do
    if SampleAppWeb.Auth.logged_in?(conn) do
      changeset = Multimedia.change_micropost(%Micropost{})
      user = Accounts.set_relations(conn.assigns.current_user)
      microposts = Multimedia.list_micropost_feed(user, params)

      conn
      |> render(:logged_in_home, changeset: changeset, microposts: microposts, user: user)
    else
      render(conn, :home)
    end
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
