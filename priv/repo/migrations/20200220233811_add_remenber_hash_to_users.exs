defmodule SampleApp.Repo.Migrations.AddRemenberHashToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :remember_hash, :string
    end
  end
end
