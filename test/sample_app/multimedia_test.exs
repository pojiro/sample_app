defmodule SampleApp.MultimediaTest do
  use SampleApp.DataCase, async: true

  alias SampleApp.Multimedia

  test "order should be most recent first" do
    user = activated_user_fixture()
    micropost_attrs = micropost_attrs(user)

    micropost_attrs
    |> Enum.each(fn {_key, attr} ->
      {:ok, micropost} = Multimedia.create_micropost(attr)

      {:ok, _micropost} =
        micropost
        |> Ecto.Changeset.change(%{inserted_at: attr.inserted_at})
        |> SampleApp.Repo.update()
    end)

    assert micropost_attrs[:most_recent].inserted_at ==
             List.first(Multimedia.list_microposts(:inserted_at, :desc)).inserted_at
  end

  test "associated microposts should be deleted" do
    user = activated_user_fixture()
    micropost_attrs = micropost_attrs(user)

    micropost_attrs
    |> Enum.each(fn {_key, attr} ->
      {:ok, _micropost} = Multimedia.create_micropost(attr)
    end)

    assert Enum.count(Multimedia.list_microposts()) > 0
    SampleApp.Accounts.delete_user(user)
    assert Enum.count(Multimedia.list_microposts()) == 0
  end
end
