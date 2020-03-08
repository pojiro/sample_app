defmodule SampleAppWeb.StaticPageController do
  use SampleAppWeb, :controller

  alias SampleApp.{Multimedia, Multimedia.Micropost}

  def home(conn, params) do
    if SampleAppWeb.Auth.logged_in?(conn) do
      changeset = Multimedia.change_micropost(%Micropost{})
      microposts = Multimedia.list_microposts(conn.assigns.current_user, params)

      conn
      |> put_view(SampleAppWeb.MicropostView)
      |> render(:post, changeset: changeset, microposts: microposts)
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
