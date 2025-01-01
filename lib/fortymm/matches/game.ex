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

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:status, :match_id])
    |> validate_required([:status, :match_id])
    |> foreign_key_constraint(:match_id)
  end
end
