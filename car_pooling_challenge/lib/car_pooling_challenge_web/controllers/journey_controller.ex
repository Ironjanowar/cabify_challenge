defmodule CarPoolingChallengeWeb.JourneyController do
  use CarPoolingChallengeWeb, :controller
  import Ecto.Query

  alias CarPoolingChallenge.Group
  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.Repo

  @doc """

  Validates the input parameters with the CarPoolingChallenge.Group
  schema. Then assign a car to the group if possible.

  """
  def journey(conn, params) do
    with group_changeset <- Group.changeset(%Group{}, params),
         true <- group_changeset.valid?,
         {:ok, group} <- Repo.insert(group_changeset) do
      Car.assign_car(group)
      conn |> send_resp(200, "")
    else
      _ -> conn |> send_resp(400, "")
    end
  end

  @doc """

  Validates the input parameters and checks if the given ID exists in the
  database. After that the given group is removed from the database.

  """
  def dropoff(conn, params) do
    with id when not is_nil(id) <- params["ID"],
         query <- from(g in Group, where: g.id == ^id, preload: [:car]),
         group when not is_nil(group) <- Repo.one(query),
         {:ok, group} <- Repo.delete(group) do
      car_id = group.car.id
      q = from(c in Car, where: c.id == ^car_id)
      car = q |> Repo.one()
      Ecto.Changeset.change(car, free_seats: car.free_seats + group.people) |> Repo.update()

      conn |> send_resp(200, "")
    else
      _ -> conn |> send_resp(400, "")
    end
  end

  @doc """

  Validates the input parameters and searches for the given group in
  the database. Returns via HTTP the car where the group is or nothing
  if the group is waiting to be assigned to a car.

  """
  def locate(conn, params) do
    with {:param, {:ok, id}} <- {:param, Map.fetch(params, "ID")},
         query <- from(g in Group, where: g.id == ^id, preload: [:car]),
         {:group, group} when not is_nil(group) <- {:group, Repo.one(query)},
         {:car, car} when not is_nil(car) <- {:car, Map.get(group, :car)} do
      conn |> render("car.json", %{car: car})
    else
      {:param, _} -> conn |> send_resp(400, "")
      {:group, _} -> conn |> send_resp(404, "")
      {:car, _} -> conn |> send_resp(204, "")
      _ -> conn |> send_resp(500, "")
    end
  end
end
