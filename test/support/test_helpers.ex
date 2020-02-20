defmodule SampleApp.TestHelpers do
  alias SampleApp.{Accounts, Accounts.User}

  def users(name) do
    users = %{
      michael: %{
        name: "Michael Example",
        email: "michael@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    users[name]
  end

  def user_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(users(:michael))
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> user_attrs()
      |> Accounts.register_user()

    user
  end
end
