defmodule CarPoolingChallenge.Car do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias CarPoolingChallenge.Repo
  alias __MODULE__

  @primary_key {:id, :id, autogenerate: false}

  schema "cars" do
    field(:free_seats, :integer)
    field(:seats, :integer)
    has_many(:groups, CarPoolingChallenge.Group, on_delete: :delete_all)
  end

  @doc false
  def changeset(car, attrs) do
    car
    |> cast(attrs, [:id, :seats])
    |> validate_inclusion(:seats, 4..6)
    |> validate_required([:id, :seats])
    |> put_change(:free_seats, attrs[:seats] || attrs["seats"])
  end

  @doc """

  Tries to place a given group into an available car. If there is no
  available car, returns :no_car.

  NOTE: There is no optimization for placing the groups by now.

  """
  def assign_car(group) do
    query = from(c in Car, where: c.free_seats >= ^group.people, preload: [:groups])

    case Repo.all(query) do
      [car | _] ->
        Ecto.Changeset.change(car, groups: [group], free_seats: car.free_seats - group.people)
        |> Repo.update()

      _ ->
        :no_car
    end
  end
end
