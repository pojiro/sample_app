defmodule SampleAppWeb.EmailTest do
  use SampleAppWeb.ConnCase

  import SampleAppWeb.Email

  alias SampleApp.Accounts

  describe "account_activation" do
    test "email involves valid information" do
      {:ok, user} = Accounts.register_user_with_activation_token(user_attrs())
      mail = account_activation(user)
      assert mail.to == user.email
      assert mail.html_body =~ "target=\"_blank\""
      assert mail.html_body =~ "rel=\"noopener\""
    end
  end
end
