defmodule SampleAppWeb.SessionController do
  use SampleAppWeb, :controller

  alias SampleAppWeb.SessionHelper

  def new(conn, _) do
    render(conn, "new.html", page_title: "Log in")
  end

  def create(conn, %{"session" => session}) do
    %{"email" => email, "password" => password, "remember_me" => remember_me} = session

    user = SampleApp.Accounts.get_user_by(email: email)

    case SampleApp.Accounts.authenticate_user(user, password: password) do
      {:ok, user} ->
        conn
        |> SampleAppWeb.Auth.login(user)
        |> SampleAppWeb.Auth.remember_user(user, remember_me)
        |> put_flash(:info, "Welcome back!")
        |> SessionHelper.redirect_back_or(Routes.static_page_path(conn, :home))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    if SampleAppWeb.Auth.logged_in?(conn) do
      conn
      |> SampleAppWeb.Auth.logout()
      |> SampleAppWeb.Auth.forget_user(conn.assigns.current_user)
      |> redirect(to: Routes.static_page_path(conn, :home))
    else
      conn
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end
end
