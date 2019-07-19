defmodule CarPoolingChallenge.Group do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias __MODULE__
  alias CarPoolingChallenge.Car
  alias CarPoolingChallenge.Repo

  @primary_key {:id, :id, autogenerate: false}

  schema "groups" do
    field(:people, :integer)
    belongs_to(:car, CarPoolingChallenge.Car)

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:id, :people, :car_id])
    |> validate_inclusion(:people, 1..6)
    |> validate_required([:id, :people])
    |> unique_constraint(:id, name: :groups_pkey)
  end

  @doc """

  Checks the groups that are not in a car and tries to assign them to
  one.

  This function is usually called after a new '/cars' request.

  """
  def assign_groups() do
    q = from(g in Group, where: is_nil(g.car_id), order_by: [asc: g.inserted_at], preload: [:car])

    q |> Repo.all() |> Enum.each(&Car.assign_car/1)
  end
end
