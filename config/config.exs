# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
# config :affinaty,
#   ecto_repos: [Affinaty.Repo]

# Configures the endpoint
config :affinaty, Affinaty.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "ZBK361kxF6L80CZiG9Mv4Ht/DxnVfy0dbueHg/kDxN4OIG0jQI7kPtw68KmGEpx6",
  render_errors: [view: Affinaty.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Affinaty.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure guardian
config :guardian, Guardian,
  issuer: "Affinaty",
  ttl: { 3, :days },
  verify_issuer: true,
  serializer: Affinaty.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
