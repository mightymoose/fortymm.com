defmodule Fortymm.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :score, :integer, null: false
      add :scoring_proposal_id, references(:scoring_proposals, on_delete: :nothing), null: false
      add :match_participant_id, references(:match_participants, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:scores, [:scoring_proposal_id])
    create index(:scores, [:match_participant_id])
    create unique_index(:scores, [:scoring_proposal_id, :match_participant_id])
  end
end
