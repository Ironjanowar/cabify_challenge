defmodule CarPoolingChallenge.Model.Group do
  alias __MODULE__
  alias CarPoolingChallenge.Model.Car
  alias CarPoolingChallenge.MemoryDatabase

  import Ecto.Changeset

  defstruct [:id, :people, :car_id, :inserted_at]

  @type t() :: %__MODULE__{
          id: integer(),
          people: integer(),
          car_id: integer(),
          inserted_at: DateTime.t()
        }

  defp type() do
    %{
      id: :integer,
      people: :integer,
      car_id: :integer,
      inserted_at: :utc_datetime
    }
  end

  @doc """

  Validates a map and creates a changeset

  """
  @spec changeset(map()) :: Ecto.Changeset.t(Group.t())
  def changeset(attrs) do
    {%Group{}, type()}
    |> cast(attrs, [:id, :people, :car_id])
    |> validate_inclusion(:people, 1..6)
    |> validate_required([:id, :people])
    |> put_change(:inserted_at, DateTime.utc_now())
  end

  @doc """

  Validates and creates a new group

  """
  @spec new(map()) :: {:ok, Group.t()} | {:error, :bad_params}
  def new(attrs) do
    changeset = changeset(attrs)

    if changeset.valid? do
      changeset
      |> Ecto.Changeset.apply_changes()
      |> MemoryDatabase.insert()
    else
      {:error, :bad_params}
    end
  end

  @doc """

  Gets a group by id

  """
  @spec get(integer()) :: {:ok, Group.t()} | {:error, :not_found}
  def get(id), do: MemoryDatabase.get_group(id)

  @doc """

  Deletes the given group

  """
  @spec delete(integer()) :: {:ok, Group.t()} | {:error, :not_found}
  def delete(id), do: MemoryDatabase.delete_group(id)

  @doc """

  Gets the unassigned groups from the database

  """
  @spec get_unassigned_groups() :: [Group.t()]
  def get_unassigned_groups(), do: MemoryDatabase.get_unassigned_groups()

  @doc """

  Assigns a group to a car, subtracting the pertinent free seats to
  the car.

  """
  @spec new_journey(Group.t(), Car.t()) :: :ok
  def new_journey(group, car) do
    MemoryDatabase.new_journey(group, car)
  end
end
