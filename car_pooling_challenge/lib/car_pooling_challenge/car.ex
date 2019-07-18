defmodule CarPoolingChallenge.Car do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> put_change(:free_seats, attrs[:seats])
  end
end
