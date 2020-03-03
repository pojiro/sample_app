defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  plug :logged_in_user when action in [:index, :show, :edit, :update, :delete]
  plug :correct_user when action in [:edit, :update]
  plug :admin_user when action in [:delete]

  import SampleApp.Helper, only: [convert_to_atom_key_map: 2]

  alias SampleApp.Accounts
  alias SampleApp.Accounts.User

  def index(conn, params) do
    users = Accounts.list_by_page(params)
    render(conn, "index.html", users: users, page_title: "All users")
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset, page_title: "Sign up")
  end

  def create(conn, %{"user" => user_params}) do
    user_params = convert_to_atom_key_map(User, user_params)

    case Accounts.register_user_with_activation_token(user_params) do
      {:ok, user} ->
        Accounts.send_account_activation_email(user)

        conn
        |> put_flash(:info, "Please check your email to activate your account.")
        |> redirect(to: Routes.static_page_path(conn, :home))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user, page_title: user.name)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset, page_title: "Edit user")
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    user_params = convert_to_atom_key_map(User, user_params)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
