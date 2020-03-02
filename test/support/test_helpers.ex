defmodule SampleApp.TestHelpers do
  alias SampleApp.{Accounts}
  alias SampleAppWeb.Router.Helpers, as: Routes

  @endpoint SampleAppWeb.Endpoint

  def user_attrs(name) when is_atom(name) do
    users = %{
      michael: %{
        name: "Michael Example",
        email: "michael@example.com",
        password: "password",
        password_confirmation: "password",
        admin: false,
        activated: false,
        activated_at: nil
      },
      archer: %{
        name: "Sterling Archer",
        email: "duchess@example.com",
        password: "password",
        password_confirmation: "password",
        admin: false,
        activated: false,
        activated_at: nil
      },
      admin: %{
        name: "Administrator",
        email: "admin@example.com",
        password: "password",
        password_confirmation: "password",
        admin: true,
        activated: false,
        activated_at: nil
      }
    }

    users[name]
  end

  def user_attrs(attrs) when is_map(attrs) do
    attrs
    |> Enum.into(user_attrs(:michael))
  end

  def user_attrs(), do: user_attrs(:michael)

  def user_fixture(name \\ :michael)

  def user_fixture(name) when is_atom(name) do
    {:ok, user} =
      user_attrs(name)
      |> Accounts.register_user_with_activation_token()

    user
  end

  def user_fixture(attrs) when is_map(attrs) do
    {:ok, user} =
      attrs
      |> Enum.into(user_attrs(:michael))
      |> Accounts.register_user_with_activation_token()

    user
  end

  def admin_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(user_attrs(:admin))
      |> Accounts.register_admin_user()

    user
  end

  def activated_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      user_fixture(attrs)
      |> Accounts.activate_user()

    user
  end

  def activated_admin_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      admin_user_fixture(attrs)
      |> Accounts.activate_user()

    user
  end

  def login(conn, user, remember_me \\ "false") do
    # :createでconnにsessionを設定する
    # Phoenixはdispatch(getやpostの繰り替えし)において自動的にrecycleをする
    # sessionやcookieはrecycle時に消えない
    # conn.assignsは消える
    conn
    |> Phoenix.ConnTest.dispatch(@endpoint, :post, Routes.session_path(conn, :create), %{
      session: %{
        "email" => user.email,
        "password" => user.password,
        "remember_me" => remember_me
      }
    })
  end
end
