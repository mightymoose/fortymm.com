defmodule Fortymm.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Repo

  @valid_match_lengths [1, 3, 5, 7]

  def valid_match_lengths, do: @valid_match_lengths

  schema "matches" do
    field :status, Ecto.Enum, values: [:pending, :in_progress, :completed, :cancelled, :abandoned]
    field :maximum_number_of_games, :integer

    has_many :match_participants, Fortymm.Matches.MatchParticipant
    has_many :users, through: [:match_participants, :user]
    has_many :games, Fortymm.Matches.Game

    timestamps(type: :utc_datetime)
  end

  def load_games(match) do
    Repo.preload(match, :games)
  end

  def load_participants(match) do
    Repo.preload(match, :match_participants)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:status, :maximum_number_of_games])
    |> validate_required([:status, :maximum_number_of_games])
    |> validate_inclusion(:maximum_number_of_games, valid_match_lengths())
  end
end
