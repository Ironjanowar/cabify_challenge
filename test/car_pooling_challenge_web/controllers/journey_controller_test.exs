defmodule CarPoolingChallengeWeb.JourneyControllerTest do
  use CarPoolingChallengeWeb.ConnCase

  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.Group

  describe "Journey" do
    test "creation and assign the group of people to a car", %{conn: conn} do
      {:ok, car_changeset} = %{"id" => 1, "seats" => 6} |> Car.check_params()
      {:ok, _car} = Car.insert(car_changeset)

      group = %{"id" => 1, "people" => 3}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(200)

      assert response =~ ""
    end

    test "creation without assigning the group of people to a car", %{conn: conn} do
      group = %{"id" => 1, "people" => 3}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(200)

      assert response =~ ""
    end

    test "creation with a repeated group id", %{conn: conn} do
      group = %{"id" => 1, "people" => 3}
      Group.new(group)

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(400)

      assert response =~ "That id already exists"
    end

    test "creation bad format", %{conn: conn} do
      group = %{"id" => 1}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(400)

      assert response =~ ""
    end

    test "creation with people out of range", %{conn: conn} do
      group = %{"id" => 1, "people" => 8}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(400)

      assert response =~ ""
    end
  end

  describe "Dropoff" do
    test "a group in a journey", %{conn: conn} do
      {:ok, car_changeset} = %{"id" => 1, "seats" => 6} |> Car.check_params()
      {:ok, _car} = Car.insert(car_changeset)

      {:ok, group} = %{"id" => 1, "people" => 3} |> Group.new()
      Car.assign_car(group)

      dropoff = %{"ID" => group.id}

      response =
        conn
        |> post(Routes.journey_path(conn, :dropoff), dropoff)
        |> response(200)

      assert response =~ ""
    end

    test "a non existing group", %{conn: conn} do
      dropoff = %{"ID" => 1}

      response =
        conn
        |> post(Routes.journey_path(conn, :dropoff), dropoff)
        |> response(404)

      assert response =~ ""
    end

    test "with a bad format", %{conn: conn} do
      dropoff = %{}
      response = conn |> post(Routes.journey_path(conn, :dropoff), dropoff) |> response(400)

      assert response =~ ""
    end
  end

  describe "Locate" do
    test "a group in a car", %{conn: conn} do
      {:ok, car_changeset} = %{"id" => 1, "seats" => 6} |> Car.check_params()
      {:ok, car} = Car.insert(car_changeset)

      {:ok, group} = %{"id" => 1, "people" => 3} |> Group.new()
      Car.assign_car(group)

      locate = %{"ID" => group.id}

      response =
        conn
        |> post(Routes.journey_path(conn, :locate), locate)
        |> json_response(200)

      assert response["id"] == car.id
    end

    test "a group waiting for a car", %{conn: conn} do
      {:ok, group} = %{"id" => 1, "people" => 3} |> Group.new()

      locate = %{"ID" => group.id}

      response =
        conn
        |> post(Routes.journey_path(conn, :locate), locate)
        |> response(204)

      assert response =~ ""
    end
  end
end
