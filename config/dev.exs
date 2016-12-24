use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :affinaty, Affinaty.Endpoint,
  http: [port: 1155],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  # watchers: []
  watchers: [node: ["node_modules/.bin/lsc", "architect.ls"]]
  # watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin"]]
  # watchers: [node: ["node_modules/.bin/gobble", "watch", "priv/static"]]

# Watch static and templates for browser reloading.
config :affinaty, Affinaty.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
# config :affinaty, Affinaty.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: "postgres",
#   password: "postgres",
#   database: "affinaty_dev",
#   hostname: "localhost",
#   pool_size: 10

config :affinaty, Affinaty.Repo,
  adapter: Mongo.Ecto,
  database: "affinaty",
  # username: "mongodb",
  # password: "mongodb",
  hostname: "localhost"

# Guardian configuration
config :guardian, Guardian,
  secret_key: "W9cDv9fjPtsYv2gItOcFb5PzmRzqGkrOsJGmby0KpBOlHJIlhxMKFmIlcCG9PVFQ"
