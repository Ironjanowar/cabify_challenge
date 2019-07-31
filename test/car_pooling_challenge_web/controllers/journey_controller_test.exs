defmodule CarPoolingChallengeWeb.JourneyControllerTest do
  use CarPoolingChallengeWeb.ConnCase

  alias CarPoolingChallenge.Model.Car
  alias CarPoolingChallenge.Model.Group
  alias CarPoolingChallenge.GroupAssigner
  alias CarPoolingChallenge.MemoryDatabase

  describe "Journey" do
    test "creation and assign the group of people to a car", %{conn: conn} do
      MemoryDatabase.start_link()

      {:ok, car} = %{"id" => 1, "seats" => 6} |> Car.check_params()
      Car.insert_all([car])

      group = %{"id" => 1, "people" => 3}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(200)

      assert response =~ ""
    end

    test "creation without assigning the group of people to a car", %{conn: conn} do
      MemoryDatabase.start_link()

      group = %{"id" => 1, "people" => 3}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(200)

      assert response =~ ""
    end

    test "creation with a repeated group id", %{conn: conn} do
      MemoryDatabase.start_link()

      group = %{"id" => 1, "people" => 3}
      Group.new(group)

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(400)

      assert response =~ "That id already exists"
    end

    test "creation bad format", %{conn: conn} do
      MemoryDatabase.start_link()

      group = %{"id" => 1}

      response =
        conn
        |> post(Routes.journey_path(conn, :journey), group)
        |> response(400)

      assert response =~ ""
    end

    test "creation with people out of range", %{conn: conn} do
      MemoryDatabase.start_link()

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
      MemoryDatabase.start_link()

      {:ok, car} = %{"id" => 3, "seats" => 6} |> Car.check_params()
      Car.insert_all([car])

      {:ok, group} = %{"id" => 2, "people" => 3} |> Group.new()
      GroupAssigner.assign() |> Task.await()

      dropoff = %{"ID" => to_string(group.id)}

      response =
        conn
        |> post(Routes.journey_path(conn, :dropoff), dropoff)
        |> response(200)

      assert response =~ ""
    end

    test "a non existing group", %{conn: conn} do
      MemoryDatabase.start_link()

      dropoff = %{"ID" => "2"}

      response =
        conn
        |> post(Routes.journey_path(conn, :dropoff), dropoff)
        |> response(404)

      assert response =~ ""
    end

    test "with a bad format", %{conn: conn} do
      MemoryDatabase.start_link()

      dropoff = %{}
      response = conn |> post(Routes.journey_path(conn, :dropoff), dropoff) |> response(400)

      assert response =~ ""
    end
  end

  describe "Locate" do
    test "a group in a car", %{conn: conn} do
      MemoryDatabase.start_link()

      {:ok, car} = %{"id" => 2, "seats" => 6} |> Car.check_params()
      Car.insert_all([car])

      {:ok, group} = %{"id" => 3, "people" => 3} |> Group.new()

      GroupAssigner.assign() |> Task.await()

      locate = %{"ID" => to_string(group.id)}

      response =
        conn
        |> post(Routes.journey_path(conn, :locate), locate)
        |> json_response(200)

      assert response["id"] == car.id
    end

    test "a group waiting for a car", %{conn: conn} do
      MemoryDatabase.start_link()

      {:ok, group} = %{"id" => 4, "people" => 3} |> Group.new()

      locate = %{"ID" => to_string(group.id)}

      response =
        conn
        |> post(Routes.journey_path(conn, :locate), locate)
        |> response(204)

      assert response =~ ""
    end
  end
end
