defmodule CarPoolingChallenge.GroupAssignerTest do
  alias CarPoolingChallenge.GroupAssigner
  alias CarPoolingChallenge.Group
  alias CarPoolingChallenge.Car

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

    groups |> Enum.each(&Group.new/1)
    cars |> Enum.each(&(Car.check_params(&1) |> elem(1) |> Car.insert()))

    unassigned_groups = Group.get_unassigned_groups()
    refute length(unassigned_groups) == 0

    task = GroupAssigner.assign()
    Task.await(task)

    unassigned_groups = Group.get_unassigned_groups()
    assert length(unassigned_groups) == 0
  end
end
