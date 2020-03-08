defmodule SampleApp.Repo.Migrations.AddPictureToMicroposts do
  use Ecto.Migration

  def change do
    alter table(:microposts) do
      add :picture, :string
    end
  end
end
