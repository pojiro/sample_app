defmodule SampleAppWeb.StaticPageViewTest do
  use SampleAppWeb.ConnCase, async: true
  use Phoenix.HTML

  import Phoenix.View
  import SampleAppWeb.LayoutView

  @home_path Routes.static_page_path(@endpoint, :home)
  @help_path Routes.static_page_path(@endpoint, :help)
  @about_path Routes.static_page_path(@endpoint, :about)
  @contact_path Routes.static_page_path(@endpoint, :contact)

  test "layout links", %{conn: conn} do
    conn = get(conn, "/")
    html = html_response(conn, 200)

    content =
      render_to_string(
        SampleAppWeb.StaticPageView,
        "home.html",
        conn: @endpoint
      )

    assert html =~ content

    assert html =~
             safe_to_string(content_tag(:a, "Home", href: @home_path))

    assert html =~
             safe_to_string(content_tag(:a, "Help", href: @help_path))

    assert html =~
             safe_to_string(content_tag(:a, "About", href: @about_path))

    assert html =~
             safe_to_string(content_tag(:a, "Contact", href: @contact_path))
  end

  test "contact title", %{conn: conn} do
    conn = get(conn, @contact_path)
    html = html_response(conn, 200)
    assert html =~ full_title("Contact")
  end
end
