defmodule SampleAppWeb.AccountActivationController do
  use SampleAppWeb, :controller

  alias SampleApp.Accounts

  def edit(conn, %{"email" => email, "id" => token} = _params) do
    user = Accounts.get_user_by(email: email)

    case Accounts.authenticate_user(user, activation_token: token) do
      {:ok, user} ->
        Accounts.activate_user(user)

        conn
        |> SampleAppWeb.Auth.login(user)
        |> put_flash(:success, "Account activated!")
        |> redirect(to: Routes.static_page_path(conn, :home))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid activation link")
        |> redirect(to: Routes.static_page_path(conn, :home))
    end
  end
end
