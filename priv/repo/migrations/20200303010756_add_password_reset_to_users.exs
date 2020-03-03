defmodule SampleApp.Repo.Migrations.AddPasswordResetToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :password_reset_hash, :string
    end
  end
end
