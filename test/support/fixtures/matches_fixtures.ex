defmodule Fortymm.MatchesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fortymm.Matches` context.
  """

  alias Fortymm.AccountsFixtures

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
end
