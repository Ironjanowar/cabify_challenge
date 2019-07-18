defmodule CarPoolingChallengeWeb.Router do
  use CarPoolingChallengeWeb, :router

  pipeline :api do
    plug(:accepts, ["json", "urlencoded"])
  end

  scope "/", CarPoolingChallengeWeb do
    pipe_through(:api)

    get("/status", StatusController, :status)
    put("/cars", CarsController, :set_cars)
  end
end
