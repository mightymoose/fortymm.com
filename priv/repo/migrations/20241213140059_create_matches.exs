defmodule Fortymm.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :status, :string
      add :maximum_number_of_games, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
