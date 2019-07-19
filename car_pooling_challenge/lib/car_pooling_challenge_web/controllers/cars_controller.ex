defmodule CarPoolingChallengeWeb.CarsController do
  use CarPoolingChallengeWeb, :controller

  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.Group
  alias CarPoolingChallenge.Repo

  require Logger

  @doc """

  Validates the input parameters. Since the expected parameter is a list of
  cars, Phoenix delivers it paired with the "_json" key.

  All the cars are validated and if any of them is not valid all the
  input is consedered invalid.

  """
  def set_cars(conn, %{"_json" => cars}) do
    with cars_changeset <- Enum.map(cars, &Car.changeset(%Car{}, &1)),
         false <- Enum.map(cars_changeset, & &1.valid?) |> Enum.member?(false),
         true <- ids_unique?(cars_changeset),
         _ <- Repo.delete_all(Car),
         nil <-
           cars_changeset
           |> Enum.map(&Repo.insert/1)
           |> Enum.find(fn {status, _} -> status == :error end) do
      # Check if there are any groups waiting
      Group.assign_groups()

      conn |> send_resp(200, "")
    else
      err ->
        err |> inspect |> Logger.error()
        conn |> send_resp(400, "")
    end
  end

  ## Utils
  defp ids_unique?([id | rest]) when is_integer(id) do
    if Enum.member?(rest, id) do
      false
    else
      ids_unique?(rest)
    end
  end

  defp ids_unique?([]), do: true

  defp ids_unique?(cars_changeset) do
    cars_changeset
    |> Enum.map(& &1.changes.id)
    |> ids_unique?()
  end
end
