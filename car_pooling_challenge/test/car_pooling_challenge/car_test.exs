defmodule CarPoolingChallenge.CarTest do
  use ExUnit.Case

  import Ecto.Query

  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.Group
  alias CarPoolingChallenge.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CarPoolingChallenge.Repo)
  end

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

    test "Assigns a car to a group" do
      valid_data = %{id: 1, seats: 4}
      car_changeset = Repo.preload(%Car{}, :groups) |> Car.changeset(valid_data)
      {:ok, car} = Repo.insert(car_changeset)
      group = %Group{id: 1, people: 3}
      Car.assign_car(group)

      q = from(c in Car, where: c.id == ^car.id, preload: [:groups])
      inserted_car = Repo.one(q)

      keys = [:id, :people]

      inserted_group = inserted_car.groups |> Enum.find(fn g -> g.id == group.id end)

      assert Map.take(inserted_group, keys) == Map.take(group, keys)
    end
  end
end
