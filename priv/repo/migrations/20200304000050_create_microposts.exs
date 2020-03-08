defmodule SampleApp.Repo.Migrations.CreateMicroposts do
  use Ecto.Migration

  def change do
    create table(:microposts) do
      add :content, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:microposts, [:user_id, :inserted_at])
  end
end
