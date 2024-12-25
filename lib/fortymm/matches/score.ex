defmodule Fortymm.Matches.Score do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scores" do
    field :score, :integer
    belongs_to :scoring_proposal, Fortymm.Matches.ScoringProposal
    belongs_to :match_participant, Fortymm.Matches.MatchParticipant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(score, attrs) do
    score
    |> cast(attrs, [:score, :match_participant_id])
    |> validate_required([:score, :match_participant_id])
    |> validate_number(:score, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:scoring_proposal_id)
    |> foreign_key_constraint(:match_participant_id)
    |> unique_constraint([:scoring_proposal_id, :match_participant_id])
  end
end
