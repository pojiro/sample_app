defmodule SampleApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SampleApp.Repo

  alias SampleApp.Accounts.User
  alias SampleAppWeb.{Email, Mailer}

  @activation_token_max_age {:max_age, 24 * 60 * 60}
  @activation_token_salt "activation_token"

  @password_reset_token_salt "reset_password_token"

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc false
  def list_by_page(params) do
    Repo.paginate(User, params)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc false
  def get_user_by(params), do: Repo.get_by(User, params)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def register_user_with_activation_token(attrs \\ %{}) do
    token = SampleApp.Helper.generate_onetime_token()
    signed_token = Phoenix.Token.sign(SampleAppWeb.Endpoint, @activation_token_salt, token)
    attrs = Map.put(attrs, :activation_token, signed_token)

    %User{}
    |> User.registration_with_activation_token_changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def register_admin_user(attrs \\ %{}) do
    %User{}
    |> User.administrator_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def update_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc false
  def remember_user(%User{} = user, %{remember_token: _token} = attrs) do
    user
    |> User.remembrance_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc false
  def change_password(%User{} = user) do
    User.password_changeset(user, %{})
  end

  @doc false
  def activate_user(%User{} = user) do
    user
    |> User.activation_changeset(%{activated: true, activated_at: NaiveDateTime.utc_now()})
    |> Repo.update()
  end

  @doc false
  def deactivate_user(%User{} = user) do
    user
    |> User.activation_changeset(%{activated: false})
    |> Repo.update()
  end

  @doc false
  def password_reset(%User{} = user) do
    token = SampleApp.Helper.generate_onetime_token()
    signed_token = Phoenix.Token.sign(SampleAppWeb.Endpoint, @password_reset_token_salt, token)

    user
    |> User.password_reset_changeset(%{password_reset_token: signed_token})
    |> Repo.update()
  end

  @doc false
  def authenticate_user(nil, _) do
    Pbkdf2.no_user_verify()
    {:error, :not_found}
  end

  def authenticate_user(%User{activated: false} = _user, password: _) do
    {:error, :not_activated}
  end

  def authenticate_user(%User{} = user, password: password) do
    cond do
      Pbkdf2.verify_pass(password, user.password_hash) ->
        {:ok, user}

      true ->
        {:error, :unauthorized}
    end
  end

  def authenticate_user(%User{} = user, remember_token: remember_token) do
    cond do
      Pbkdf2.verify_pass(remember_token, user.remember_hash) ->
        {:ok, user}

      true ->
        {:error, :unauthorized}
    end
  end

  def authenticate_user(%User{} = user, activation_token: activation_token) do
    {:ok, _} =
      Phoenix.Token.verify(SampleAppWeb.Endpoint, @activation_token_salt, activation_token, [
        @activation_token_max_age
      ])

    cond do
      Pbkdf2.verify_pass(activation_token, user.activation_hash) ->
        {:ok, user}

      true ->
        {:error, :unauthorized}
    end
  end

  def authenticate_user(%User{} = user, password_reset_token: token, max_age: max_age) do
    case Phoenix.Token.verify(SampleAppWeb.Endpoint, @password_reset_token_salt, token,
           max_age: max_age
         ) do
      {:ok, _} ->
        cond do
          Pbkdf2.verify_pass(token, user.password_reset_hash) -> {:ok, user}
          true -> {:error, :unauthorized}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def send_account_activation_email(%User{} = user) do
    Email.account_activation(user) |> Mailer.deliver_now()
  end

  def send_password_reset_email(%User{} = user) do
    Email.password_reset(user) |> Mailer.deliver_now()
  end

  def delete_password_reset_hash(user) do
    {:ok, user} =
      user
      |> User.password_hash_changeset(%{password_reset_hash: nil})
      |> Repo.update()

    user
  end
end
