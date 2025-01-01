defmodule Fortymm.Matches do
  @moduledoc """
  The Matches context.
  """

  import Ecto.Query, warn: false
  alias Fortymm.Repo

  alias Fortymm.Matches.Match
  alias Fortymm.Matches.Challenge
  alias Fortymm.Matches.MatchParticipant
  alias Fortymm.Matches.Game
  alias Fortymm.Matches.ChallengeUpdates
  alias Fortymm.Accounts.User
  alias Fortymm.Matches.ScoringProposal
  alias Fortymm.Matches.ScoringUpdates
  alias Fortymm.Matches.ScoringProposalResolution

  def complete_game(game_id) do
    game_id
    |> get_game!()
    |> Game.changeset(%{status: :completed})
    |> Repo.update()
    |> maybe_complete_match()
  end

  defp maybe_complete_match({:ok, game}) do
    match =
      game.match_id
      |> get_match!()
      |> Match.load_scoring()
      |> Match.load_users()

    case Match.winner(match) do
      nil ->
        {:ok, new_game} = create_game(%{match_id: match.id, status: :in_progress})
        {:match_not_completed, new_game}

      winner ->
        {:ok, match} = update_match(match, %{status: :completed})
        {:match_completed, match, winner}
    end
  end

  defp maybe_complete_match(error), do: error

  defp get_game!(game_id), do: Repo.get!(Game, game_id)

  def create_scoring_proposal_resolution(attrs \\ %{}) do
    %ScoringProposalResolution{}
    |> ScoringProposalResolution.changeset(attrs)
    |> Repo.insert()
  end

  def create_scoring_proposal(attrs \\ %{}) do
    %ScoringProposal{}
    |> ScoringProposal.changeset(attrs)
    |> Repo.insert()
    |> broadcast_scoring_proposal_created()
  end

  defp broadcast_scoring_proposal_created({:ok, scoring_proposal}) do
    ScoringUpdates.broadcast_scoring_proposal_created(scoring_proposal)
    {:ok, scoring_proposal}
  end

  defp broadcast_scoring_proposal_created(error), do: error

  def change_scoring_proposal(%ScoringProposal{} = scoring_proposal, attrs \\ %{}) do
    ScoringProposal.changeset(scoring_proposal, attrs)
  end

  def subscribe_to_challenge_updates() do
    ChallengeUpdates.subscribe()
  end

  def subscribe_to_scoring_updates() do
    ScoringUpdates.subscribe()
  end

  def create_match_participant(attrs \\ %{}) do
    %MatchParticipant{}
    |> MatchParticipant.changeset(attrs)
    |> Repo.insert()
  end

  def create_challenge(attrs \\ %{}) do
    %Challenge{}
    |> Challenge.changeset(attrs)
    |> Repo.insert()
  end

  def scoring_proposals_for_game(game_id) do
    ScoringProposal
    |> ScoringProposal.for_game(game_id)
    |> Repo.all()
    |> ScoringProposal.load_scores()
  end

  def get_scoring_proposal!(id),
    do:
      ScoringProposal
      |> Repo.get!(id)
      |> ScoringProposal.load_scores()

  def get_challenge!(id), do: Repo.get!(Challenge, id)

  def change_challenge(%Challenge{} = challenge, attrs \\ %{}) do
    Challenge.changeset(challenge, attrs)
  end

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches do
    Repo.all(Match)
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id), do: Repo.get!(Match, id)

  @doc """
  Creates a match from a challenge, marking the challenge as accepted and creating match participants.

  ## Examples

      iex> create_match_from_challenge(challenge, user)
      {:ok, %{match: %Match{}, updated_challenge: %Challenge{}, participants: [%MatchParticipant{}, %MatchParticipant{}]}}

      iex> create_match_from_challenge(challenge, bad_user)
      {:error, failed_operation, failed_value, changes_so_far}

  """
  def create_match_from_challenge(%Challenge{} = challenge, %User{} = user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:match, fn _changes ->
      Match.changeset(%Match{}, %{
        maximum_number_of_games: challenge.maximum_number_of_games,
        status: :in_progress
      })
    end)
    |> Ecto.Multi.update(:updated_challenge, fn %{match: match} ->
      Challenge.accept_changeset(challenge, %{match_id: match.id, accepted_by_id: user.id})
    end)
    |> Ecto.Multi.insert(:first_game, fn %{match: match} ->
      Game.changeset(%Game{}, %{
        match_id: match.id,
        status: :in_progress
      })
    end)
    |> Ecto.Multi.insert_all(:participants, MatchParticipant, fn %{match: match} ->
      [
        %{
          match_id: match.id,
          user_id: challenge.created_by_id,
          inserted_at: now,
          updated_at: now
        },
        %{
          match_id: match.id,
          user_id: user.id,
          inserted_at: now,
          updated_at: now
        }
      ]
    end)
    |> Repo.transaction()
    |> broadcast_challenge_accepted()
  end

  defp broadcast_challenge_accepted({:ok, %{updated_challenge: challenge}} = result) do
    ChallengeUpdates.broadcast_challenge_accepted(challenge)
    result
  end

  defp broadcast_challenge_accepted(error), do: error

  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_match(attrs \\ %{}) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{data: %Match{}}

  """
  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end
end
