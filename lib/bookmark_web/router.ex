defmodule BookmarkWeb.Router do
  use BookmarkWeb, :router

  import BookmarkWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BookmarkWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BookmarkWeb do
    pipe_through :browser

    live "/", PageLive, :index
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: BookmarkWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", BookmarkWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :put_session_layout]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", BookmarkWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", BookmarkWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/bookmark", BookmarksLive.Index, :index
    live "/bookmark/new", BookmarksLive.New, :new
    live "/bookmark/new-test", BookmarksLive.New, :test_custom
    live "/bookmark/new-test-select", BookmarksLive.New, :test_existing
    live "/bookmark/:id/edit", BookmarksLive.Edit, :edit
    live "/bookmark/:id", BookmarksLive.Show, :show
    live "/bookmark/:id/show/edit", BookmarksLive.Show, :edit
  end

  scope "/", BookmarkWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/contexts", ContextsLive.Index, :index
    live "/contexts/new", ContextsLive.New, :new
    live "/contexts/:id/edit", ContextsLive.Edit, :edit
    live "/contexts/:id", ContextsLive.Show, :show
    live "/contexts/:id/show/edit", ContextsLive.Show, :edit
  end

  scope "/", BookmarkWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
