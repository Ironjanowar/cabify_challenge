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

  Assigns the car that leaves less free space.

  """
  def assign_car(group) do
    query =
      from(c in Car,
        where: c.free_seats >= ^group.people,
        order_by: [asc: c.free_seats - ^group.people],
        preload: [:groups],
        limit: 1
      )

    case Repo.all(query) do
      [] ->
        :no_car

      [car] ->
        Ecto.Changeset.change(car,
          groups: [group | car.groups],
          free_seats: car.free_seats - group.people
        )
        |> Repo.update()
    end
  end

  @doc """

  Check if given params are valid to create a car.

  """
  def check_params(params) do
    car_changeset = Car.changeset(%Car{}, params)

    if car_changeset.valid? do
      {:ok, car_changeset}
    else
      {:error, :bad_params}
    end
  end

  @doc """

  Creates a new car with given changeset.

  """
  def insert(changeset), do: Repo.insert(changeset)

  @doc """

  Takes a car id and returns that car if it exists in the
  database.

  """
  def get(id) do
    q = from(c in Car, where: c.id == ^id, preload: [:groups])

    case q |> Repo.one() do
      nil -> {:error, :car_not_found}
      car -> {:ok, car}
    end
  end

  @doc """

  Receives a car and the number of seats to be freed and updates the
  car on the database.

  """
  def free_seats(car, seats) do
    changeset = Ecto.Changeset.change(car, free_seats: car.free_seats + seats)
    Repo.update(changeset)
  end

  @doc """

  Deletes all cars

  """
  def delete_all() do
    Repo.delete_all(Car)
  end

  @doc """
  Creates new cars from a list of changesets
  """
  def insert_all(changesets) do
    Enum.each(changesets, &Car.insert/1)
  end
end
