defmodule Affinaty.Router do
  use Affinaty.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  # scope "/", alias: AffinatyCPanel, host: "cpanel.affinaty.com" do
  # # scope "/", AffinatyCPanel  do
  #   pipe_through :browser # Use the default browser stack
  #
  #   get "/", PageController, :index
  # end

  # Other scopes may use custom stacks.
  scope "/api", Affinaty do
    pipe_through :api

    resources "/identity", IdentityController, only: [:index, :create]

    post "/sign-in", SessionController, :create
    get "/sign-in", SessionController, :create  # temporary
    delete "/sign-out", SessionController, :delete
  end

  scope "/plugin", Affinaty do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :plugin
  end

  scope "/", Affinaty do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end

end
