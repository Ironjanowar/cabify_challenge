use Mix.Config

config :car_pooling_challenge, CarPoolingChallengeWeb.Endpoint,
  url: [port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
