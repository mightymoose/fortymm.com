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
  alias Fortymm.Accounts.User

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
        status: :pending
      })
    end)
    |> Ecto.Multi.update(:updated_challenge, fn %{match: match} ->
      Challenge.accept_changeset(challenge, %{match_id: match.id, accepted_by_id: user.id})
    end)
    |> Ecto.Multi.insert(:first_game, fn %{match: match} ->
      Game.changeset(%Game{}, %{
        match_id: match.id,
        status: :pending
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
  end

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
