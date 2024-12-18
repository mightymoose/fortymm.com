defmodule Fortymm.Repo.Migrations.CreateChallenges do
  use Ecto.Migration

  def change do
    create table(:challenges) do
      add :maximum_number_of_games, :integer, null: false
      add :match_id, references(:matches, on_delete: :nothing)
      add :created_by_id, references(:users, on_delete: :nothing), null: false
      add :accepted_by_id, references(:users, on_delete: :nothing)
      add :rejected_by_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:challenges, [:match_id])
  end
end
