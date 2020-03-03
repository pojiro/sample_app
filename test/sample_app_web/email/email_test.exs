defmodule SampleAppWeb.EmailTest do
  use SampleAppWeb.ConnCase

  alias SampleAppWeb.Email
  alias SampleApp.Accounts

  describe "account_activation" do
    test "email involves valid information" do
      {:ok, user} = Accounts.register_user_with_activation_token(user_attrs())
      mail = Email.account_activation(user)
      assert mail.to == user.email

      assert mail.html_body =~
               "#{
                 Routes.account_activation_url(
                   SampleAppWeb.Endpoint,
                   :edit,
                   user.activation_token,
                   email: user.email
                 )
               }"

      assert mail.html_body =~ "target=\"_blank\""
      assert mail.html_body =~ "rel=\"noopener\""
    end
  end

  describe "password_reset" do
    setup do
      user = activated_user_fixture()
      {:ok, user: user}
    end

    test "email involves valid information", %{conn: _conn, user: user} do
      {:ok, user} = Accounts.password_reset(user)
      mail = Email.password_reset(user)
      assert mail.to == user.email

      assert mail.html_body =~
               "#{
                 Routes.password_reset_url(
                   SampleAppWeb.Endpoint,
                   :edit,
                   user.password_reset_token,
                   email: user.email
                 )
               }"

      assert mail.html_body =~ "target=\"_blank\""
      assert mail.html_body =~ "rel=\"noopener\""
    end
  end
end
