defmodule SampleAppWeb.LayoutView do
  use SampleAppWeb, :view

  @base_title "Phoenix Sample App"
  def full_title(nil), do: @base_title
  def full_title(page_title), do: page_title <> " | " <> @base_title
end
