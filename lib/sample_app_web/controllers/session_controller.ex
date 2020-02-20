defmodule SampleAppWeb.SessionController do
  use SampleAppWeb, :controller

  def new(conn, _) do
    render(conn, "new.html", page_title: "Log in")
  end

  def create(
        conn,
        %{"session" => %{"email" => email, "password" => password}}
      ) do
    case SampleApp.Accounts.authenticate_by_email_and_password(email, password) do
      {:ok, user} ->
        conn
        |> SampleAppWeb.Auth.login(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.static_page_path(conn, :home))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> SampleAppWeb.Auth.logout()
    |> redirect(to: Routes.static_page_path(conn, :home))
  end
end
