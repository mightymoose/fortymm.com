defmodule Fortymm.Matches.ScoringProposal do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Accounts.User
  alias Fortymm.Matches.Game
  alias Fortymm.Matches.Score

  schema "scoring_proposals" do
    belongs_to :game, Game
    belongs_to :created_by, User

    has_many :scores, Score

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scoring_proposal, attrs) do
    scoring_proposal
    |> cast(attrs, [:game_id, :created_by_id])
    |> cast_assoc(:scores, with: &Score.changeset/2)
    |> validate_required([:game_id, :created_by_id])
    |> foreign_key_constraint(:game_id)
    |> foreign_key_constraint(:created_by_id)
    |> validate_scores()
  end

  defp validate_scores(changeset) do
    changeset
    |> validate_length(:scores, is: 2)
    |> validate_someone_won()
    |> validate_deuce()
  end

  defp validate_someone_won(changeset) do
    scores = get_field(changeset, :scores)

    if Enum.all?(scores, fn score -> score.score < 11 end) do
      add_error(changeset, :scores, "Someone must have won")
    else
      changeset
    end
  end

  defp validate_deuce(changeset) do
    scores = get_field(changeset, :scores)

    winner = Enum.max_by(scores, fn score -> score.score end, fn -> %Score{score: 0} end)
    loser = Enum.min_by(scores, fn score -> score.score end, fn -> %Score{score: 0} end)

    went_to_deuce? = winner.score > 11
    won_by_two_points? = winner.score - loser.score == 2

    if went_to_deuce? && !won_by_two_points? do
      add_error(changeset, :scores, "The scores must go to deuce")
    else
      changeset
    end
  end
end
