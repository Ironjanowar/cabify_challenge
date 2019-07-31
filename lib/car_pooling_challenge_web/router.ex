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
    match(:*, "/status", FallbackController, :invalid_method)

    put("/cars", CarsController, :set_cars)
    match(:*, "/cars", FallbackController, :invalid_method)

    post("/journey", JourneyController, :journey)
    match(:*, "/journey", FallbackController, :invalid_method)
  end

  scope "/", CarPoolingChallengeWeb do
    pipe_through(:api_urlencoded)

    post("/dropoff", JourneyController, :dropoff)
    match(:*, "/dropoff", FallbackController, :invalid_method)

    post("/locate", JourneyController, :locate)
    match(:*, "/locate", FallbackController, :invalid_method)
  end
end
