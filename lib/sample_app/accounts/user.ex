defmodule SampleApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :remember_token, :string, virtual: true
    field :remember_hash, :string
    field :admin, :boolean
    field :activation_token, :string, virtual: true
    field :activation_hash, :string
    field :activated, :boolean
    field :activated_at, :naive_datetime

    timestamps()
  end

  @doc false
  @valid_email_regex ~r/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_length(:name, max: 50)
    |> validate_length(:email, max: 255)
    |> validate_format(:email, @valid_email_regex)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password, message: "does not match password")
    |> put_pass_hash()
  end

  def registration_with_activation_token_changeset(user, attrs) do
    user
    |> registration_changeset(attrs)
    |> cast(attrs, [:activation_token])
    |> validate_required([:activation_token])
    |> put_activation_token_hash
  end

  def administrator_changeset(user, params) do
    user
    |> registration_changeset(params)
    |> cast(params, [:admin])
    |> validate_required([:admin])
  end

  def update_changeset(user, %{password: "", password_confirmation: ""} = attrs) do
    changeset(user, attrs)
  end

  def update_changeset(user, attrs) do
    registration_changeset(user, attrs)
  end

  def activation_changeset(user, params) do
    user
    |> cast(params, [:activated, :activated_at])
    |> validate_required([:activated])
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end

  def remembrance_changeset(user, attrs) do
    user
    |> cast(attrs, [:remember_token])
    |> put_remember_token_hash()
  end

  defp put_remember_token_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{remember_token: token}} ->
        put_change(changeset, :remember_hash, Pbkdf2.hash_pwd_salt(token))

      _ ->
        changeset
    end
  end

  defp put_activation_token_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{activation_token: token}} ->
        put_change(changeset, :activation_hash, Pbkdf2.hash_pwd_salt(token))

      _ ->
        changeset
    end
  end
end
