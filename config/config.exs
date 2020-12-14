# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bookmark,
  ecto_repos: [Bookmark.Repo]

# Configures the endpoint
config :bookmark, BookmarkWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DpHoNUnvBHdSNosezLJO/3ZnjuOApADUabU0h267rRVXIpZ3RR/3KGUvRq6hmoFp",
  render_errors: [view: BookmarkWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bookmark.PubSub,
  live_view: [signing_salt: "KED+uPKs"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
