defmodule CarPoolingChallenge.GroupAssigner do
  alias CarPoolingChallenge.Model.Car
  alias CarPoolingChallenge.Model.Group

  defp assign_car(group) do
    car =
      Car.get_free_cars()
      |> Enum.filter(fn car -> car.free_seats >= group.people end)
      |> Enum.sort_by(fn car -> car.free_seats - group.people end)
      |> Enum.take(1)

    case car do
      [] ->
        :no_car

      [car] ->
        Group.new_journey(group, car)
    end
  end

  @doc """

  Executes a dropoff, deletes the group from the database and free the
  seats of the car assigned (if it is the case)

  """
  @spec dropoff(integer()) :: {:ok, Group.t()} | {:error, :not_found}
  def dropoff(id) do
    case Group.delete(id) do
      {:ok, %{car_id: car_id} = group} = ok when not is_nil(car_id) ->
        Car.free_seats(group.car_id, group.people)
        ok

      rest ->
        # This could be a not found error or an ok if the group was
        # not assigned
        rest
    end
  end

  @doc """

  Creates an asyncronous task that tries to assign cars to groups that
  are waiting for it

  """
  @spec assign() :: Task.t()
  def assign() do
    Task.async(fn ->
      groups = Group.get_unassigned_groups()
      Enum.each(groups, &assign_car/1)
    end)
  end
end
