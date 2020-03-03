defmodule SampleAppWeb.PasswordResetController do
  use SampleAppWeb, :controller
  plug :check_expiration when action in [:edit, :update]

  import SampleApp.Helper, only: [convert_to_atom_key_map: 2]

  alias SampleApp.{Accounts, Accounts.User}

  @password_reset_token_max_age 2 * 60 * 60

  defp check_expiration(%{params: %{"email" => email, "id" => token}} = conn, _) do
    user = Accounts.get_user_by(email: email)

    case Accounts.authenticate_user(user,
           password_reset_token: token,
           max_age: @password_reset_token_max_age
         ) do
      {:ok, user} ->
        assign(conn, :user, user)

      {:error, :expired} ->
        conn
        |> put_flash(:warning, "Password reset has expired.")
        |> redirect(to: Routes.password_reset_path(conn, :new))
        |> halt()

      {:error, _} ->
        conn
        |> put_flash(:warning, "Invalid Password reset link.")
        |> redirect(to: Routes.static_page_path(conn, :home))
        |> halt()
    end
  end

  def new(conn, _params) do
    render(conn, "new.html", page_title: "Forgot password")
  end

  def create(conn, %{"email" => email} = _params) do
    user = Accounts.get_user_by(email: email)

    if user do
      {:ok, user} = Accounts.password_reset(user)
      Accounts.send_password_reset_email(user)

      conn
      |> put_flash(:info, "Email sent with password reset instructions")
      |> redirect(to: Routes.static_page_path(conn, :home))
    else
      conn
      |> put_flash(:warning, "Email address not found")
      |> render("new.html", page_title: "Forgot password")
    end
  end

  def edit(conn, %{"email" => _email, "id" => token} = _params) do
    user = conn.assigns.user
    changeset = Accounts.change_password(user)

    render(conn, "edit.html",
      user: user,
      password_reset_token: token,
      changeset: changeset,
      page_title: "Reset password"
    )
  end

  def update(conn, %{"email" => email, "id" => token, "user" => user_params} = _params) do
    user = Accounts.get_user_by(email: email)
    user_params = convert_to_atom_key_map(User, user_params)

    case Accounts.update_password(user, user_params) do
      {:ok, user} ->
        user = Accounts.delete_password_reset_hash(user)

        conn
        |> SampleAppWeb.Auth.login(user)
        |> put_flash(:info, "Password has been reset.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, password_reset_token: token, changeset: changeset)
    end
  end
end
