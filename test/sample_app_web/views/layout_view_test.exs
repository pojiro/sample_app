defmodule SampleAppWeb.LayoutViewTest do
  use SampleAppWeb.ConnCase, async: true

  # When testing helpers, you may want to import Phoenix.HTML and
  # use functions such as safe_to_string() to convert the helper
  # result into an HTML string.
  # import Phoenix.HTML
  import SampleAppWeb.LayoutView

  test "full title helper" do
    assert full_title(nil) == "Phoenix Sample App"
    assert full_title("Help") == "Help | Phoenix Sample App"
  end
end
