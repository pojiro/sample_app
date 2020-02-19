defmodule SampleApp.Repo.Migrations.AddUniqueIndexToUsers do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS citext"

    alter table("users") do
      modify :email, :citext
    end

    create unique_index(:users, [:email])
  end

  def down do
    drop unique_index(:users, [:email])

    alter table("users") do
      modify :email, :string
    end

    execute "DROP EXTENSION IF EXISTS citext"
  end
end
