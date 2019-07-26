defmodule CarPoolingChallenge.CarTest do
  use CarPoolingChallenge.DataCase

  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.Repo

  describe "cars" do
    test "Creates a car with valid data" do
      valid_data = %{id: 1, seats: 4}
      car = Car.changeset(%Car{}, valid_data)

      assert car.valid?
    end

    test "Tries to create a car with invalid data" do
      invalid_data = %{id: 1}
      car = Car.changeset(%Car{}, invalid_data)

      refute car.valid?
    end

    test "Tries to create a car with seats out of range" do
      invalid_data = %{id: 1, seats: 10}
      car = Car.changeset(%Car{}, invalid_data)

      refute car.valid?
    end

    test "Gets a car" do
      valid_data = %{id: 1, seats: 4}
      car_changeset = Car.changeset(%Car{}, valid_data)
      {:ok, car} = Repo.insert(car_changeset)

      result = Car.get(car.id)

      assert elem(result, 0) == :ok
    end
  end
end
