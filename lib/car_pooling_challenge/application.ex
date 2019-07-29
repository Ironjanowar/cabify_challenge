defmodule CarPoolingChallenge.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      CarPoolingChallenge.Repo,
      CarPoolingChallengeWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: CarPoolingChallenge.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    CarPoolingChallengeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
