defmodule SampleAppWeb.Email do
  use Bamboo.Phoenix, view: SampleAppWeb.EmailView

  alias SampleApp.Accounts.User

  def account_activation(%User{} = user) do
    base()
    |> subject("Your Account Activation Link")
    |> to(user.email)
    |> assign(:user, user)
    |> render(:account_activation)
  end

  defp base do
    new_email()
    |> from("SampleApp<noreply@tombo-works.com>")
    |> put_html_layout({SampleAppWeb.LayoutView, "email.html"})
    |> put_text_layout({SampleAppWeb.LayoutView, "email.text"})
  end
end
