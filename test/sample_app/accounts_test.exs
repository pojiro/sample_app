defmodule SampleApp.AccountsTest do
  use SampleApp.DataCase

  alias SampleApp.Accounts

  @invalid_attrs user_attrs(%{name: "", email: ""})
  @update_attrs user_attrs(%{name: "updater", email: "update@example.com"})

  describe "users" do
    alias SampleApp.Accounts.User

    test "list_users/0 returns all users" do
      user = user_fixture()
      [listed_user] = Accounts.list_users()
      assert listed_user.name == user.name
      assert listed_user.email == user.email
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      got_user = Accounts.get_user!(user.id)
      assert got_user.name == user.name
      assert got_user.email == user.email
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(user_attrs())
      assert user.email == user_attrs().email
      assert user.name == user_attrs().name
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == @update_attrs.email
      assert user.name == @update_attrs.name
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      got_user = Accounts.get_user!(user.id)
      assert got_user.name == user.name
      assert got_user.email == user.email
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "enforces unique email" do
      assert {:ok, %User{id: id} = user} = Accounts.register_user(user_attrs())

      assert {:error, changeset} =
               %{email: String.upcase(user_attrs().email)}
               |> Enum.into(user_attrs())
               |> Accounts.register_user()

      assert %{email: ["has already been taken"]} = errors_on(changeset)

      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "authenticate user by activation token" do
      assert {:ok, user} = Accounts.register_user_with_activation_token(user_attrs())

      assert {:ok, user} =
               Accounts.authenticate_user(user, activation_token: user.activation_token)
    end

    test "authenticate user by password reset token" do
      assert {:ok, user} = Accounts.password_reset(activated_user_fixture())

      assert {:ok, user} =
               Accounts.authenticate_user(user,
                 password_reset_token: user.password_reset_token,
                 max_age: 10
               )
    end

    test "authenticate user by expired password reset token" do
      assert {:ok, user} = Accounts.password_reset(activated_user_fixture())

      assert {:error, :expired} =
               Accounts.authenticate_user(user,
                 password_reset_token: user.password_reset_token,
                 max_age: -10
               )
    end
  end
end
