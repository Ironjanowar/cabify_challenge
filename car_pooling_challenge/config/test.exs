use Mix.Config

# Configure your database
config :car_pooling_challenge, CarPoolingChallenge.Repo,
  username: "postgres",
  password: "postgres",
  database: "car_pooling_challenge_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :car_pooling_challenge, CarPoolingChallengeWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
