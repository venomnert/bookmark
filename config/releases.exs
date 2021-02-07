import Config

db_host =
  System.get_env("DATABASE_HOST") ||
    raise """
    environment variable DATABASE_HOST is missing.
    """

db_database = System.get_env("DATABASE_DB") || "bookmark_db"
db_username = System.get_env("DATABASE_USER") || "postgres"
db_password = System.get_env("DATABASE_PASSWORD") || "postgres"
db_url = "ecto://#{db_username}:#{db_password}@#{db_host}/#{db_database}"

config :bookmark, Bookmark.Repo,
  url: db_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

port = String.to_integer(System.get_env("PORT") || "4000")

# config :bookmark, BookmarkWeb.Endpoint,
#   http: [:inet6, port: 4000],
#   secret_key_base: secret_key_base

config :bookmark, BookmarkWeb.Endpoint,
  http: [:inet6, port: port],
  url: [host: System.get_env("HOSTNAME"), port: port],
  secret_key_base: secret_key_base
