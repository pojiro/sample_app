defmodule SampleApp.UserTest do
  use SampleApp.DataCase, async: true

  alias SampleApp.Accounts.User

  defp user_attrs(attrs) do
    Enum.into(attrs, %{
      name: "test",
      email: "test@example.com",
      password: "super secret",
      password_confirmation: "super secret"
    })
  end

  def user_changeset(attrs \\ %{}) do
    User.changeset(%User{}, user_attrs(attrs))
  end

  def user_registration_changeset(attrs \\ %{}) do
    User.registration_changeset(%User{}, user_attrs(attrs))
  end

  test "user_changeset helper" do
    assert user_changeset().valid?
  end

  test "user_registration_changeset helper" do
    assert user_registration_changeset().valid?
  end

  test "name should be non blank" do
    changeset = user_changeset(%{name: ""})
    refute changeset.valid?
  end

  test "email should be non blank" do
    changeset = user_changeset(%{email: ""})
    refute changeset.valid?
  end

  test "email addresses should be saved as downcase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    changeset = user_changeset(%{email: mixed_case_email})
    assert changeset.changes.email == String.downcase(mixed_case_email)
  end

  test "name should not be too long" do
    changeset = user_changeset(%{name: String.duplicate("a", 51)})
    refute changeset.valid?
  end

  test "email should not be too long" do
    email = String.duplicate("a", 244) <> "@example.com"
    changeset = user_changeset(%{email: email})
    refute changeset.valid?
  end

  test "email validation should accept valid addresses" do
    ~W"""
    user@example.com
    USER@foo.COM
    A_US-ER@foo.bar.org
    first.last@foo.jp
    alice+bob@baz.cn
    """
    |> Enum.each(fn
      email ->
        changeset = user_changeset(%{email: email})
        assert changeset.valid?, "#{email} should be valid"
    end)
  end

  test "email validation should reject invalid addresses" do
    ~W"""
    user@example,com
    user_at_foo.org
    user.name@example.
    foo@bar_baz.com
    foo@bar+baz.com
    foo@bar..com
    """
    |> Enum.each(fn
      email ->
        changeset = user_changeset(%{email: email})
        refute changeset.valid?, "#{email} should be valid"
    end)
  end

  test "invalid password_confirmation" do
    changeset = user_registration_changeset(%{password_confirmation: ""})
    refute changeset.valid?
  end

  test "password should be non blank" do
    changeset = user_registration_changeset(%{password: "", password_confirmation: ""})
    refute changeset.valid?
  end

  test "password should have a minimum length" do
    password = String.duplicate("a", 5)

    changeset =
      user_registration_changeset(%{password: password, password_confirmation: password})

    refute changeset.valid?
  end
end
