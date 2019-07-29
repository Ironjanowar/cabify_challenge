# General application configuration
use Mix.Config

config :car_pooling_challenge,
  ecto_repos: [CarPoolingChallenge.Repo]

# Configures the endpoint
config :car_pooling_challenge, CarPoolingChallengeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vLd2JPwnaRxQlZx2en8CfCkbpNkqh6HlRflg2YnRKbneb1AZJ5wPhpLH6jJdb9A3",
  render_errors: [view: CarPoolingChallengeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CarPoolingChallenge.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
