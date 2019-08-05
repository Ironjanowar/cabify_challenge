import Config

config :car_pooling_challenge, CarPoolingChallengeWeb.Endpoint,
  http: [port: System.get_env("PORT", "9091")],
  secret_key_base: System.get_env("SECRET_KEY_BASE", "default_secret"),
  server: true
