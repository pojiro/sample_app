defmodule SampleApp.Repo.Migrations.CreateRelationships do
  use Ecto.Migration

  def change do
    create table(:relationships) do
      add :follower_id, :integer
      add :followed_id, :integer

      timestamps()
    end

    create index(:relationships, [:follower_id])
    create index(:relationships, [:followed_id])
    create index(:relationships, [:follower_id, :followed_id], unique: true)
  end
end
