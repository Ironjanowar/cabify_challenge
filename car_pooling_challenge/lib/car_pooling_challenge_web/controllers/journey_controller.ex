defmodule CarPoolingChallengeWeb.JourneyController do
  use CarPoolingChallengeWeb, :controller

  alias CarPoolingChallenge.Group
  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.Repo

  @doc """

  Validates the input parameters with the CarPoolingChallenge.Group
  schema. Then assign a car to the group if possible.

  """
  def new_journey(conn, params) do
    with group_changeset <- Group.changeset(%Group{}, params),
         true <- group_changeset.valid?,
         {:ok, group} <- Repo.insert(group_changeset) do
      Car.assign_car(group)
      conn |> send_resp(200, "")
    else
      _ -> conn |> send_resp(400, "")
    end
  end
end
