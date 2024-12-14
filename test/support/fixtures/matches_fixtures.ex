defmodule Fortymm.MatchesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fortymm.Matches` context.
  """

  def valid_match_attributes do
    %{
      maximum_number_of_games: Enum.random(Fortymm.Matches.Match.valid_match_lengths()),
      status: Enum.random([:pending, :in_progress, :completed, :cancelled, :abandoned])
    }
  end

  def match_fixture(attrs \\ %{}) do
    {:ok, match} =
      attrs
      |> Enum.into(valid_match_attributes())
      |> Fortymm.Matches.create_match()

    match
  end
end
