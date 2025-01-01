defmodule Fortymm.Matches.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Matches.ScoringProposal

  schema "games" do
    field :status, Ecto.Enum, values: [:pending, :in_progress, :completed, :cancelled, :abandoned]
    belongs_to :match, Fortymm.Matches.Match

    has_many :scoring_proposals, ScoringProposal

    timestamps(type: :utc_datetime)
  end

  def accepted_scoring_proposal(game) do
    game.scoring_proposals
    |> Enum.find(&ScoringProposal.accepted?/1)
  end

  def winner(game) do
    case accepted_scoring_proposal(game) do
      nil ->
        nil

      scoring_proposal ->
        winning_score = Enum.max_by(scoring_proposal.scores, & &1.score)
        winning_score.match_participant
    end
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:status, :match_id])
    |> validate_required([:status, :match_id])
    |> foreign_key_constraint(:match_id)
  end
end
