defmodule SampleApp.RelationshipTest do
  use SampleApp.DataCase, async: true

  alias SampleApp.Accounts.Relationship

  def relationship_changeset(attrs \\ %{}) do
    Relationship.changeset(%Relationship{}, attrs)
  end

  test "relationship_changeset helper" do
    assert relationship_changeset(%{
             follower_id: user_fixture(:michael).id,
             followed_id: user_fixture(:archer).id
           }).valid?
  end

  test "should require a follower_id" do
    refute relationship_changeset(%{
             follower_id: user_fixture(:michael).id,
             followed_id: nil
           }).valid?
  end

  test "should require a followed_id" do
    refute relationship_changeset(%{
             follower_id: nil,
             followed_id: user_fixture(:michael).id
           }).valid?
  end
end
