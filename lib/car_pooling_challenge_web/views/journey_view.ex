defmodule CarPoolingChallengeWeb.JourneyView do
  use CarPoolingChallengeWeb, :view

  def render("car.json", %{car: car}) do
    car_json(car)
  end

  @car_json_fields [:id, :seats]
  defp car_json(car) do
    Map.take(car, @car_json_fields)
  end
end
