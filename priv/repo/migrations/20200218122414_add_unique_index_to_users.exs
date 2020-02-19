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
    alter table("users") do
      modify :email, :string
    end

    drop unique_index(:users, [:email])
  end
end
