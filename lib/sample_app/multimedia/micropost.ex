defmodule SampleApp.Multimedia.Micropost do
  use Ecto.Schema
  import Ecto.Changeset

  schema "microposts" do
    field :content, :string
    field :picture, :string
    belongs_to :user, SampleApp.Accounts.User

    timestamps()
  end

  def changeset(micropost, attrs) do
    micropost
    |> cast(attrs, [:content, :user_id])
    |> validate_required([:content, :user_id])
    |> validate_length(:content, max: 140)
    |> foreign_key_constraint(:user_id)
  end

  def picture_changeset(micropost, attrs) do
    changeset(micropost, attrs)
    |> cast(attrs, [:picture])
    |> validate_required([:picture])
    |> validate_format(:picture, ~r/.+\.(jpeg|jpg|gif|png)$/, message: "invalid extension")
  end
end
