defmodule CarPoolingChallengeWeb.CarsControllerTest do
  use CarPoolingChallengeWeb.ConnCase

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(CarPoolingChallenge.Repo, {:shared, self()})
  end

  test "Creates a list of cars and delete all the previous cars", %{conn: conn} do
    cars = [
      %{"id" => 1, "seats" => 6},
      %{"id" => 2, "seats" => 5},
      %{"id" => 3, "seats" => 4}
    ]

    body = %{"_json" => cars}

    response =
      conn
      |> put(Routes.cars_path(conn, :set_cars), body)
      |> response(200)

    assert response =~ ""
  end

  test "Tries creation with repeated ids", %{conn: conn} do
    cars = [
      %{"id" => 1, "seats" => 6},
      %{"id" => 1, "seats" => 5},
      %{"id" => 3, "seats" => 4}
    ]

    body = %{"_json" => cars}

    response =
      conn
      |> put(Routes.cars_path(conn, :set_cars), body)
      |> response(400)

    assert response =~ "Some ids are repeated"
  end

  test "Tries creation with bad format", %{conn: conn} do
    cars = [
      %{"id" => 1}
    ]

    body = %{"_json" => cars}

    response =
      conn
      |> put(Routes.cars_path(conn, :set_cars), body)
      |> response(400)

    assert response =~ ""
  end

  test "Tries creation with bad seats range", %{conn: conn} do
    cars = [
      %{"id" => 1, "seats" => 10}
    ]

    body = %{"_json" => cars}

    response =
      conn
      |> put(Routes.cars_path(conn, :set_cars), body)
      |> response(400)

    assert response =~ ""
  end
end
