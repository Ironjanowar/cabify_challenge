defmodule CarPoolingChallengeWeb.JourneyController do
  use CarPoolingChallengeWeb, :controller

  alias CarPoolingChallenge.Model.Group
  alias CarPoolingChallenge.Model.Car
  alias CarPoolingChallenge.GroupAssigner

  @doc """

  Validates the input parameters with the CarPoolingChallenge.Group
  schema. Then assign a car to the group if possible.

  """
  def journey(conn, params) do
    case Group.new(params) do
      {:ok, _group} ->
        GroupAssigner.assign()
        conn |> send_resp(200, "")

      {:error, :id_exists} ->
        conn |> send_resp(400, "That id already exists")

      {:error, :bad_params} ->
        conn |> send_resp(400, "")
    end
  end

  @doc """

  Validates the input parameters and checks if the given ID exists in
  the database. After that the given group is removed from the
  database, if they are assigned to a car it sums the number of people
  in the group to the free seats attribute from the car.

  """
  def dropoff(conn, params) do
    with id when not is_nil(id) <- params["ID"],
         id <- String.to_integer(id),
         {:ok, _group} <- GroupAssigner.dropoff(id) do
      GroupAssigner.assign()

      conn |> send_resp(200, "")
    else
      {:error, :not_found} -> conn |> send_resp(404, "Group not found")
      _ -> conn |> send_resp(400, "")
    end
  end

  @doc """

  Validates the input parameters and searches for the given group in
  the database. Returns via HTTP the car where the group is or nothing
  if the group is waiting to be assigned to a car.

  """
  def locate(conn, params) do
    with {:param, id} when not is_nil(id) <- {:param, params["ID"]},
         id <- String.to_integer(id),
         {:ok, group} <- Group.get(id),
         {:car, {:ok, car}} <- {:car, Car.get(group.car_id)} do
      conn |> render("car.json", %{car: car})
    else
      {:param, _} ->
        conn |> send_resp(400, "")

      {:error, :not_found} ->
        conn |> send_resp(404, "")

      {:car, _} ->
        conn |> send_resp(204, "")

      err ->
        IO.inspect(err)
        conn |> send_resp(500, "")
    end
  end
end
