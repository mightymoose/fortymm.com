defmodule Fortymm.Matches.ScoringProposalResolution do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scoring_proposal_resolutions" do
    field :accepted, :boolean, default: false
    field :scoring_proposal_id, :id
    field :created_by_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scoring_proposal_resolution, attrs) do
    scoring_proposal_resolution
    |> cast(attrs, [:accepted, :scoring_proposal_id, :created_by_id])
    |> validate_required([:accepted, :scoring_proposal_id, :created_by_id])
    |> foreign_key_constraint(:scoring_proposal_id)
    |> foreign_key_constraint(:created_by_id)
    |> unique_constraint([:scoring_proposal_id])
  end
end
