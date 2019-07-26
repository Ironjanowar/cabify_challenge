defmodule CarPoolingChallengeWeb.CarsController do
  use CarPoolingChallengeWeb, :controller

  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.GroupAssigner

  @doc """

  Validates the input parameters. Since the expected parameter is a list of
  cars, Phoenix delivers it paired with the "_json" key.

  All the cars are validated and if any of them is not valid all the
  input is consedered invalid.

  """
  def set_cars(conn, %{"_json" => car_params}) do
    check_params = fn car, acc ->
      case Car.check_params(car) do
        {:ok, car} -> {:cont, [car | acc]}
        _ -> {:halt, :bad_params}
      end
    end

    case Enum.reduce_while(car_params, [], check_params) do
      :bad_params ->
        conn |> send_resp(400, "")

      car_changesets ->
        if ids_unique?(car_changesets) do
          Car.delete_all()
          Car.insert_all(car_changesets)
          GroupAssigner.assign()
          conn |> send_resp(200, "")
        else
          conn |> send_resp(400, "")
        end
    end
  end

  ## Utils
  defp ids_unique?(changesets) do
    ids = Enum.map(changesets, & &1.changes.id)
    length(ids) == ids |> Enum.uniq() |> length()
  end
end
