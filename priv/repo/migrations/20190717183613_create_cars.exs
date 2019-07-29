defmodule CarPoolingChallenge.Repo.Migrations.CreateCars do
  use Ecto.Migration

  def change do
    create table(:cars, primary_key: false) do
      add :id, :bigint, primary_key: true
      add :seats, :integer
      add :free_seats, :integer
    end

  end
end
