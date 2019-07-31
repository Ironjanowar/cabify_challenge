defmodule CarPoolingChallenge.Model.Car do
  alias __MODULE__
  alias CarPoolingChallenge.MemoryDatabase

  import Ecto.Changeset

  defstruct [:id, :seats, :free_seats]

  @type t() :: %__MODULE__{
          id: integer(),
          seats: integer(),
          free_seats: integer()
        }

  defp type() do
    %{
      id: :integer,
      seats: :integer,
      free_seats: :integer
    }
  end

  @doc """

  Checks if a given map is a valid Car

  """
  def changeset(attrs) do
    {%Car{}, type()}
    |> cast(attrs, [:id, :seats])
    |> validate_inclusion(:seats, 4..6)
    |> validate_required([:id, :seats])
    |> put_change(:free_seats, attrs["seats"])
  end

  @doc """

  Receives a list of car changesets to insert them all

  """
  def insert_all(cars) do
    MemoryDatabase.insert(cars)
  end

  @doc """

  Checks if a given map is a valid car and inserts it

  """
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

  Gets a car by id

  """
  @spec get(integer()) :: {:ok, Car.t()} | {:error, :not_found}
  def get(id), do: MemoryDatabase.get_car(id)

  @doc """

  Checks if a given map is a car and returns the struct that is
  generated with its attributes

  """
  def check_params(car) do
    changeset = changeset(car)

    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, :bad_params}
    end
  end

  @doc """

  Gets all the cars with one or more seats available. The result is
  in ascending order by free seats.

  """
  def get_free_cars(), do: MemoryDatabase.get_free_cars()

  @doc """

  Frees the number of seats from a given car id

  """
  @spec free_seats(integer(), integer()) :: :ok
  def free_seats(car_id, people), do: MemoryDatabase.free_seats(car_id, people)
end
