defmodule SampleAppWeb.MicropostController do
  use SampleAppWeb, :controller

  alias SampleApp.Multimedia

  plug :logged_in_user when action in [:create, :delete]
  plug :my_micropost when action in [:delete]

  defp my_micropost(conn, _opts) do
    micropost = Multimedia.get_micropost!(conn.params["id"])

    if conn.assigns.current_user.id == micropost.user_id do
      assign(conn, :micropost, micropost)
    else
      conn
      |> redirect(to: Routes.static_page_path(conn, :home))
      |> halt()
    end
  end

  def create(conn, %{"micropost" => %{"content" => content, "picture" => picture}} = params) do
    create_impl(conn, params, %{
      content: content,
      picture: picture,
      user_id: conn.assigns.current_user.id
    })
  end

  def create(conn, %{"micropost" => %{"content" => content}} = params) do
    create_impl(conn, params, %{
      content: content,
      user_id: conn.assigns.current_user.id
    })
  end

  defp create_impl(conn, params, impl_params) do
    case Multimedia.create_micropost(impl_params) do
      {:ok, micropost} ->
        conn
        |> put_flash(:success, "Micropost created!")
        |> redirect(to: Routes.static_page_path(conn, :home))

      {:error, %Ecto.Changeset{} = changeset} ->
        microposts = Multimedia.list_microposts(conn.assigns.current_user, params)

        conn
        # |> put_view(SampleAppWeb.StaticPageView)
        # |> redirect(to: Routes.static_page_path(conn, :home))
        |> put_view(SampleAppWeb.MicropostView)
        |> render(:post, changeset: changeset, microposts: microposts)
    end
  end

  def delete(conn, %{"id" => _id} = _params) do
    {:ok, _} = Multimedia.delete_micropost(conn.assigns.micropost)
    referer = List.first(get_req_header(conn, "referer"))

    conn
    |> put_flash(:success, "Micropost deleted")
    |> redirect(external: referer)
  end
end
