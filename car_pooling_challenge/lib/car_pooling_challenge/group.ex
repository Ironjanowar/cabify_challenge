defmodule CarPoolingChallenge.Group do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias __MODULE__
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

  Returns the unassigned groups ordered by the time they have been
  waiting

  """
  def get_unassigned_groups() do
    q = from(g in Group, where: is_nil(g.car_id), order_by: [asc: g.inserted_at], preload: [:car])
    q |> Repo.all()
  end

  @doc """

  Takes a group id and returns that group if it exists in the
  database.

  """
  def get(id) do
    q = from(g in Group, where: g.id == ^id, preload: [:car])

    case q |> Repo.one() do
      nil -> {:error, :group_not_found}
      group -> {:ok, group}
    end
  end

  @doc """

  Deletes a given group from the database.

  """
  def delete(group) do
    Repo.delete(group)
  end

  @doc """

  Creates a new group in the database. The function takes a map with
  an id and a number of people, validates the data and inserts the new
  group.

  """
  def new(params) do
    group_changeset = Group.changeset(%Group{}, params)

    if group_changeset.valid? do
      Repo.insert(group_changeset)
    else
      {:error, :bad_params}
    end
  end
end
