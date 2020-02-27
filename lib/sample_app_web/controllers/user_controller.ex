defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  plug :logged_in_user when action in [:index, :show, :edit, :update, :delete]
  plug :correct_user when action in [:edit, :update]
  plug :admin_user when action in [:delete]

  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.Auth

  def index(conn, params) do
    users = Accounts.list_by_page(params)
    render(conn, "index.html", users: users, page_title: "All users")
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset, page_title: "Sign up")
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> put_flash(:success, "Welcome to the Sample App!")
        |> redirect(to: Routes.user_path(conn, :show, user))

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

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%{assigns: %{current_user: login_user}} = conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
