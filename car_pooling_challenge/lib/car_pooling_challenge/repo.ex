defmodule CarPoolingChallenge.Repo do
  use Ecto.Repo,
    otp_app: :car_pooling_challenge,
    adapter: Ecto.Adapters.Postgres
end
