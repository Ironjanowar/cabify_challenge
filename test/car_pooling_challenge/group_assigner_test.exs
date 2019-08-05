defmodule CarPoolingChallenge.GroupAssignerTest do
  use ExUnit.Case, async: false

  alias CarPoolingChallenge.GroupAssigner
  alias CarPoolingChallenge.MemoryDatabase
  alias CarPoolingChallenge.Model.Group
  alias CarPoolingChallenge.Model.Car

  setup do
    :sys.replace_state(MemoryDatabase, fn _ -> %{cars: %{}, groups: %{}} end)
  end

  test "Assigns groups to new cars" do
    cars = [
      %{"id" => 1, "seats" => 6},
      %{"id" => 2, "seats" => 5},
      %{"id" => 3, "seats" => 4}
    ]

    groups = [
      %{"id" => 1, "people" => 6},
      %{"id" => 2, "people" => 4},
      %{"id" => 3, "people" => 2}
    ]

    groups |> Enum.each(&Group.new/1)
    cars |> Enum.map(&(Car.check_params(&1) |> elem(1))) |> Car.insert_all()

    unassigned_groups = Group.get_unassigned_groups()
    refute Enum.empty?(unassigned_groups)

    GroupAssigner.assign() |> Task.await()

    unassigned_groups = Group.get_unassigned_groups()
    assert Enum.empty?(unassigned_groups)
  end

  test "Dropoff a group" do
    {:ok, group} = %{"id" => 4, "people" => 6} |> Group.new()

    status = Group.get(group.id) |> elem(0)
    assert status == :ok

    GroupAssigner.dropoff(group.id)

    status = Group.get(group.id)
    assert status == {:error, :not_found}
  end
end
