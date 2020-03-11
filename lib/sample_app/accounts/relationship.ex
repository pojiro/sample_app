defmodule SampleApp.Accounts.Relationship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "relationships" do
    belongs_to :follower, SampleApp.Accounts.User
    belongs_to :followed, SampleApp.Accounts.User

    timestamps()
  end

  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:follower_id, :followed_id])
    |> validate_required([:follower_id, :followed_id])
  end
end
