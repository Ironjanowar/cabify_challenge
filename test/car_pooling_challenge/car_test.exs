defmodule CarPoolingChallenge.CarTest do
  use ExUnit.Case

  alias CarPoolingChallenge.Model.Car
  alias CarPoolingChallenge.Model.Group
  alias CarPoolingChallenge.MemoryDatabase
  alias CarPoolingChallenge.GroupAssigner

  describe "cars" do
    test "Creates a car with valid data" do
      valid_data = %{"id" => 1, "seats" => 4}
      car = Car.changeset(valid_data)

      assert car.valid?
    end

    test "Tries to create a car with invalid data" do
      invalid_data = %{"id" => 1}
      car = Car.changeset(invalid_data)

      refute car.valid?
    end

    test "Tries to create a car with seats out of range" do
      invalid_data = %{"id" => 1, "seats" => 10}
      car = Car.changeset(invalid_data)

      refute car.valid?
    end

    test "Inserts a car" do
      MemoryDatabase.start_link()

      valid_data = %{"id" => 1, "seats" => 4}
      {:ok, car} = Car.check_params(valid_data)
      {:ok, [inserted_car]} = Car.insert_all([car])

      assert car.id == inserted_car.id
    end

    test "Gets a car" do
      MemoryDatabase.start_link()

      valid_data = %{"id" => 1, "seats" => 4}
      {:ok, car} = Car.check_params(valid_data)
      Car.insert_all([car])

      {:ok, inserted_car} = Car.get(car.id)

      assert car.id == inserted_car.id
    end

    test "Get free cars" do
      MemoryDatabase.start_link()

      cars =
        [%{"id" => 1, "seats" => 4}, %{"id" => 2, "seats" => 5}]
        |> Enum.map(fn car -> Car.check_params(car) |> elem(1) end)

      Car.insert_all(cars)
      Group.new(%{"id" => 1, "people" => 4})
      GroupAssigner.assign() |> Task.await()

      [car | _] = cars = Car.get_free_cars()

      assert length(cars) == 1
      assert car.id == 2
    end

    test "Free a number of seats" do
      MemoryDatabase.start_link()

      valid_data = %{"id" => 1, "seats" => 4}
      {:ok, car} = Car.check_params(valid_data)
      Car.insert_all([car])
      Group.new(%{"id" => 1, "people" => 4})
      GroupAssigner.assign() |> Task.await()

      {:ok, car} = Car.get(car.id)
      assert car.free_seats == 0

      Car.free_seats(car.id, 4)
      {:ok, car} = Car.get(car.id)

      assert car.free_seats == 4
    end
  end
end
