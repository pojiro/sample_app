defmodule SampleApp.MicropostTest do
  use SampleApp.DataCase, async: true

  alias SampleApp.Multimedia.Micropost

  def micropost_changeset(user, attrs \\ %{}) do
    Micropost.changeset(%Micropost{}, micropost_attrs(user, attrs))
  end

  setup do
    {:ok, user: activated_user_fixture()}
  end

  test "micropost_changeset helper", %{user: user} do
    assert micropost_changeset(user).valid?
  end

  test "content should be non blank", %{user: user} do
    changeset = micropost_changeset(user, %{content: ""})
    refute changeset.valid?
    assert %{content: ["can't be blank"]} == errors_on(changeset)
  end

  test "user should be non blank", %{user: user} do
    changeset = micropost_changeset(user, %{user_id: nil})
    refute changeset.valid?
    assert %{user_id: ["can't be blank"]} == errors_on(changeset)
  end

  test "content should be at most 140 characters", %{user: user} do
    changeset = micropost_changeset(user, %{content: String.duplicate("a", 141)})
    refute changeset.valid?
  end
end
