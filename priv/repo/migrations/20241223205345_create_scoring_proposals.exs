defmodule Fortymm.Repo.Migrations.CreateScoringProposals do
  use Ecto.Migration

  def change do
    create table(:scoring_proposals) do
      add :game_id, references(:games, on_delete: :nothing)
      add :created_by_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:scoring_proposals, [:game_id])
    create index(:scoring_proposals, [:created_by_id])
  end
end
