defmodule CarPoolingChallengeWeb.Router do
  use CarPoolingChallengeWeb, :router

  pipeline :api_json do
    plug(:accepts, ["json"])
  end

  pipeline :api_urlencoded do
    plug(:accepts, ["urlencoded", "json"])
  end

  scope "/", CarPoolingChallengeWeb do
    pipe_through(:api_json)

    get("/status", StatusController, :status)
    put("/cars", CarsController, :set_cars)
    post("/journey", JourneyController, :journey)
  end

  scope "/", CarPoolingChallengeWeb do
    pipe_through(:api_urlencoded)

    post("/dropoff", JourneyController, :dropoff)
    post("/locate", JourneyController, :locate)
  end
end
