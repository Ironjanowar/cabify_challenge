defmodule CarPoolingChallenge.GroupTest do
  use ExUnit.Case

  import Ecto.Query

  alias CarPoolingChallenge.Group
  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CarPoolingChallenge.Repo)
  end

  describe "groups" do
    test "Creates a group with valid data" do
      valid_data = %{id: 1, people: 3}
      group = Group.changeset(%Group{}, valid_data)

      assert group.valid?
    end

    test "Tries to create a group with invalid data" do
      invalid_data = %{id: 1}
      group = Group.changeset(%Group{}, invalid_data)

      refute group.valid?
    end

    test "Tries to create a group with people out of range" do
      invalid_data = %{id: 1, people: 8}
      group = Group.changeset(%Group{}, invalid_data)

      refute group.valid?
    end

    test "Assigns groups to new cars" do
      cars = [
        %{id: 1, seats: 6},
        %{id: 2, seats: 5},
        %{id: 3, seats: 4}
      ]

      groups = [
        %{id: 1, people: 6},
        %{id: 2, people: 4},
        %{id: 3, people: 2}
      ]

      groups |> Enum.map(&(Group.changeset(%Group{}, &1) |> Repo.insert()))
      cars |> Enum.map(&(Car.changeset(%Car{}, &1) |> Repo.insert()))

      q = from(g in Group, where: is_nil(g.car_id))
      groups_not_assigned = Repo.all(q)
      refute length(groups_not_assigned) == 0

      Group.assign_groups()

      groups_not_assigned = Repo.all(q)
      assert length(groups_not_assigned) == 0
    end
  end
end
