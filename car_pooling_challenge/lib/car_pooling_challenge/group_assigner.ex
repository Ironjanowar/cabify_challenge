defmodule CarPoolingChallenge.GroupAssigner do
  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.Group

  def assign() do
    Task.async(fn -> Group.get_unassigned_groups() |> Enum.each(&Car.assign_car/1) end)
  end
end
