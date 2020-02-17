defmodule SampleAppWeb.PageController do
  use SampleAppWeb, :controller

  def hello(conn, _params) do
    render(conn, "hello.html")
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
