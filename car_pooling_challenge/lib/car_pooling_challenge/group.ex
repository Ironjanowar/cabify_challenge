defmodule CarPoolingChallenge.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: false}

  schema "groups" do
    field(:people, :integer)
    belongs_to(:car, CarPoolingChallenge.Car)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:id, :people, :car_id])
    |> validate_inclusion(:people, 1..6)
    |> validate_required([:id, :people])
    |> unique_constraint(:id, name: :groups_pkey)
  end
end
