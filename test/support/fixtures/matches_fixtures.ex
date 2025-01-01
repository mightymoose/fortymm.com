defmodule Fortymm.MatchesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fortymm.Matches` context.
  """

  alias Fortymm.AccountsFixtures
  alias Fortymm.Matches
  alias Fortymm.Matches.Match

  def valid_scoring_proposal_resolution_attributes(attrs \\ %{}) do
    scoring_proposal = scoring_proposal_fixture()
    user = AccountsFixtures.user_fixture()

    attrs
    |> Enum.into(%{
      scoring_proposal_id: scoring_proposal.id,
      created_by_id: user.id
    })
  end

  def scoring_proposal_resolution_fixture(attrs \\ %{}) do
    {:ok, scoring_proposal_resolution} =
      attrs
      |> valid_scoring_proposal_resolution_attributes()
      |> Matches.create_scoring_proposal_resolution()

    scoring_proposal_resolution
  end

  def valid_score_attributes(attrs \\ %{}) do
    scoring_proposal = scoring_proposal_fixture()
    match_participant = match_participant_fixture()

    %{
      score: Enum.random(1..100),
      scoring_proposal_id: scoring_proposal.id,
      match_participant_id: match_participant.id
    }
    |> Enum.into(attrs)
  end

  def valid_scoring_proposal_attributes(attrs \\ %{}) do
    challenge = challenge_fixture()
    user = AccountsFixtures.user_fixture()

    {:ok, %{first_game: first_game, match: match}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    attrs
    |> Enum.into(%{
      game_id: first_game.id,
      created_by_id: user.id,
      scores: [
        %{match_participant_id: first_participant.id, score: 11},
        %{match_participant_id: second_participant.id, score: 0}
      ]
    })
  end

  def scoring_proposal_fixture(attrs \\ %{}) do
    {:ok, scoring_proposal} =
      attrs
      |> valid_scoring_proposal_attributes()
      |> Fortymm.Matches.create_scoring_proposal()

    scoring_proposal
  end

  def valid_match_participant_attributes(attrs \\ %{}) do
    match = match_fixture()
    user = AccountsFixtures.user_fixture()

    attrs
    |> Enum.into(%{
      user_id: user.id,
      match_id: match.id
    })
  end

  def match_participant_fixture(attrs \\ %{}) do
    {:ok, match_participant} =
      attrs
      |> valid_match_participant_attributes()
      |> Fortymm.Matches.create_match_participant()

    match_participant
  end

  def valid_challenge_attributes(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    attrs
    |> Enum.into(%{
      maximum_number_of_games: Enum.random(Fortymm.Matches.Match.valid_match_lengths()),
      created_by_id: user.id,
      match_id: nil
    })
  end

  def challenge_fixture(attrs \\ %{}) do
    {:ok, challenge} =
      attrs
      |> valid_challenge_attributes()
      |> Fortymm.Matches.create_challenge()

    challenge
  end

  def valid_match_attributes(attrs \\ %{}) do
    %{
      maximum_number_of_games: Enum.random(Fortymm.Matches.Match.valid_match_lengths()),
      status: Enum.random([:pending, :in_progress, :completed, :cancelled, :abandoned])
    }
    |> Enum.into(attrs)
  end

  def match_fixture(attrs \\ %{}) do
    {:ok, match} =
      attrs
      |> valid_match_attributes()
      |> Fortymm.Matches.create_match()

    match
  end

  def valid_game_attributes(attrs \\ %{}) do
    match = match_fixture()

    %{
      status: :pending,
      match_id: match.id
    }
    |> Enum.into(attrs)
  end

  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> valid_game_attributes()
      |> Fortymm.Matches.create_game()

    game
  end
end
