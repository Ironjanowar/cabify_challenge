defmodule CarPoolingChallengeWeb.JourneyControllerTest do
  use CarPoolingChallengeWeb.ConnCase

  describe "Journey creation" do
    test "Creates a journey and assigns the group of people to a car" do
      cars = %{"_json" => [%{"id" => 1, "seats" => 6}]}
      group = %{"id" => 1, "people" => 3}

      car_conn = build_conn()
      car_conn |> put(Routes.cars_path(car_conn, :set_cars), cars)

      group_conn = build_conn()

      response =
        group_conn
        |> post(Routes.journey_path(group_conn, :journey), group)
        |> response(200)

      assert response =~ ""
    end

    test "Creates a journey without assigning the group of people to a car", %{conn: conn} do
      group = %{"id" => 1, "people" => 3}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(200)

      assert response =~ ""
    end

    test "Tries to create a journey with bad format", %{conn: conn} do
      group = %{"id" => 1}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(400)

      assert response =~ ""
    end

    test "Tries to create a journey with people out of range", %{conn: conn} do
      group = %{"id" => 1, "people" => 8}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(400)

      assert response =~ ""
    end
  end

  describe "Dropoff from journey" do
    test "Dropoff a group in a journey" do
      cars = %{"_json" => [%{"id" => 1, "seats" => 6}]}
      car_conn = build_conn()
      car_conn |> put(Routes.cars_path(car_conn, :set_cars), cars)

      group = %{"id" => 1, "people" => 3}
      group_conn = build_conn()
      group_conn |> post(Routes.journey_path(group_conn, :journey), group)

      dropoff = %{"ID" => group["id"]}
      dropoff_conn = build_conn()

      response =
        dropoff_conn
        |> post(Routes.journey_path(dropoff_conn, :dropoff), dropoff)
        |> response(200)

      assert response =~ ""
    end

    test "Dropoff a non existing group", %{conn: conn} do
      dropoff = %{"ID" => 1}

      response =
        conn
        |> post(Routes.journey_path(conn, :dropoff), dropoff)
        |> response(404)

      assert response =~ ""
    end

    test "Dropoff with a bad format", %{conn: conn} do
      dropoff = %{}
      response = conn |> post(Routes.journey_path(conn, :dropoff), dropoff) |> response(400)

      assert response =~ ""
    end
  end

  describe "Locate journeys" do
    test "Locate group in car" do
      car = %{"id" => 1, "seats" => 6}
      cars = %{"_json" => [car]}
      car_conn = build_conn()
      car_conn |> put(Routes.cars_path(car_conn, :set_cars), cars)

      group = %{"id" => 1, "people" => 3}
      group_conn = build_conn()
      group_conn |> post(Routes.journey_path(group_conn, :journey), group)

      locate = %{"ID" => group["id"]}
      locate_conn = build_conn()

      response =
        locate_conn
        |> post(Routes.journey_path(locate_conn, :locate), locate)
        |> json_response(200)

      assert response == car
    end

    test "Locate group waiting for a car" do
      group = %{"id" => 1, "people" => 3}
      group_conn = build_conn()
      group_conn |> post(Routes.journey_path(group_conn, :journey), group)

      locate = %{"ID" => group["id"]}
      locate_conn = build_conn()

      response =
        locate_conn
        |> post(Routes.journey_path(locate_conn, :locate), locate)
        |> response(204)

      assert response =~ ""
    end
  end
end
