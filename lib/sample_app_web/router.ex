defmodule SampleAppWeb.Router do
  use SampleAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SampleAppWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SampleAppWeb do
    pipe_through :browser

    get "/hello", PageController, :hello
    get "/", StaticPageController, :home

    get "/home", StaticPageController, :home
    get "/about", StaticPageController, :about
    get "/help", StaticPageController, :help
    get "/contact", StaticPageController, :contact

    get "/signup", UserController, :new
    post "/signup", UserController, :create

    resources "/users", UserController, except: [:new, :create] do
      get "/following", UserController, :following, as: :follow
      get "/followers", UserController, :followers, as: :follow
    end

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/login", SessionController, :delete

    resources "/account_activation", AccountActivationController, only: [:edit]
    resources "/password_reset", PasswordResetController, only: [:new, :create, :edit, :update]
    resources "/microposts", MicropostController, only: [:create, :delete]
    resources "/relationships", RelationshipController, only: [:create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", SampleAppWeb do
  #   pipe_through :api
  # end

  if Mix.env() == :dev do
    forward "/emails", Bamboo.SentEmailViewerPlug
  end
end
