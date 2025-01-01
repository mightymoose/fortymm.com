defmodule Fortymm.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Repo
  alias Fortymm.Matches.Game

  @valid_match_lengths [1, 3, 5, 7]

  def valid_match_lengths, do: @valid_match_lengths

  schema "matches" do
    field :status, Ecto.Enum, values: [:pending, :in_progress, :completed, :cancelled, :abandoned]
    field :maximum_number_of_games, :integer

    has_many :match_participants, Fortymm.Matches.MatchParticipant
    has_many :users, through: [:match_participants, :user]
    has_many :games, Game

    timestamps(type: :utc_datetime)
  end

  def load_scoring(match) do
    Repo.preload(match,
      games: [
        scoring_proposals: [
          :scoring_proposal_resolution,
          :created_by,
          scores: [:match_participant]
        ]
      ]
    )
  end

  def winner(match) do
    {winning_so_far, games_won} =
      match.games
      |> Enum.group_by(&Game.winner/1)
      |> Enum.max_by(fn {_winner, games} -> length(games) end)

    cond do
      winning_so_far == nil ->
        nil

      length(games_won) >= match.maximum_number_of_games / 2 ->
        winning_so_far

      true ->
        nil
    end
  end

  def load_games(match) do
    Repo.preload(match, :games)
  end

  def load_participants(match) do
    Repo.preload(match, :match_participants)
  end

  def load_users(match) do
    Repo.preload(match, match_participants: :user)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:status, :maximum_number_of_games])
    |> validate_required([:status, :maximum_number_of_games])
    |> validate_inclusion(:maximum_number_of_games, valid_match_lengths())
  end
end
