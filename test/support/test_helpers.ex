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
        admin: false
      },
      archer: %{
        name: "Sterling Archer",
        email: "duchess@example.com",
        password: "password",
        password_confirmation: "password",
        admin: false
      },
      admin: %{
        name: "Administrator",
        email: "admin@example.com",
        password: "password",
        password_confirmation: "password",
        admin: true
      }
    }

    users[name]
  end

  def user_attrs(attrs) when is_map(attrs) do
    attrs
    |> Enum.into(user_attrs(:michael))
  end

  def user_attrs(), do: user_attrs(:michael)

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(user_attrs(:michael))
      |> Accounts.register_user()

    user
  end

  def admin_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(user_attrs(:admin))
      |> Accounts.register_admin_user()

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
