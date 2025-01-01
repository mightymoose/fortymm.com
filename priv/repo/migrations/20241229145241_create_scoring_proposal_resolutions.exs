defmodule Fortymm.Repo.Migrations.CreateScoringProposalResolutions do
  use Ecto.Migration

  def change do
    create table(:scoring_proposal_resolutions) do
      add :accepted, :boolean, default: false, null: false
      add :scoring_proposal_id, references(:scoring_proposals, on_delete: :nothing)
      add :created_by_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:scoring_proposal_resolutions, [:scoring_proposal_id])
    create index(:scoring_proposal_resolutions, [:created_by_id])
  end
end
