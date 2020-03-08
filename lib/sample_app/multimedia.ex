defmodule SampleApp.Multimedia do
  @moduledoc """
  The Multimedia context.
  """

  import Ecto.Query, warn: false
  alias SampleApp.Repo

  alias SampleApp.Accounts.User
  alias SampleApp.Multimedia.Micropost

  def change_micropost(%Micropost{} = micropost) do
    Micropost.changeset(micropost, %{})
  end

  def list_microposts() do
    Repo.all(Micropost)
  end

  def list_microposts(:inserted_at, :desc) do
    # query = from m in Micropost, order_by: [desc: m.inserted_at]
    # Repo.all(query)
    Micropost
    |> order_by([m], desc: m.inserted_at)
    |> Repo.all()
  end

  def list_microposts(%User{} = user, params) do
    Micropost
    |> where([m], m.user_id == ^user.id)
    |> join(:inner, [m], u in User, on: m.user_id == u.id)
    |> preload(:user)
    |> order_by([m], desc: m.inserted_at)
    |> Repo.paginate(params)
  end

  def get_micropost!(id), do: Repo.get!(Micropost, id)

  def create_micropost(%{picture: picture} = attrs) do
    extension = picture.filename |> Path.extname() |> String.downcase()
    filename = "#{SampleApp.Helper.random_string(32)}#{extension}"
    attrs = Map.replace!(attrs, :picture, filename)

    result =
      %Micropost{}
      |> Micropost.picture_changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, _} ->
        :ok = File.cp!(picture.path, "priv/uploads/#{filename}")
        result

      {:error, _} ->
        result
    end
  end

  def create_micropost(attrs) do
    %Micropost{}
    |> Micropost.changeset(attrs)
    |> Repo.insert()
  end

  def delete_micropost(%Micropost{picture: nil} = micropost) do
    Repo.delete(micropost)
  end

  def delete_micropost(%Micropost{} = micropost) do
    picture_path = "priv/uploads/#{micropost.picture}"
    if File.exists?(picture_path), do: File.rm!(picture_path)
    Repo.delete(micropost)
  end
end
