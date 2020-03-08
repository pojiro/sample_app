defmodule SampleAppWeb.PartialView do
  use SampleAppWeb, :view

  import SampleAppWeb.UserView, only: [gravatar_for: 2]
end
