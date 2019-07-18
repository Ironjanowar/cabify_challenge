defmodule CarPoolingChallenge.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :bigint, primary_key: true
      add :people, :integer
      add :car_id, references(:cars), null: true
    end

  end
end
