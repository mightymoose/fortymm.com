defmodule Fortymm.Matches.MatchTest do
  use Fortymm.DataCase
  import Fortymm.MatchesFixtures

  alias Fortymm.Matches.Match

  test "is valid with valid attributes" do
    changeset = Match.changeset(%Match{}, valid_match_attributes())
    assert changeset.valid?
  end

  test "is invalid without a status" do
    attributes = valid_match_attributes() |> Map.put(:status, nil)
    changeset = Match.changeset(%Match{}, attributes)
    refute changeset.valid?
  end

  test "is invalid with a maximum number of games not in valid_match_lengths" do
    attributes = valid_match_attributes() |> Map.put(:maximum_number_of_games, 10)
    changeset = Match.changeset(%Match{}, attributes)
    refute changeset.valid?
  end

  test "is invalid with a status that is not a valid match status" do
    attributes = valid_match_attributes() |> Map.put(:status, :invalid)
    changeset = Match.changeset(%Match{}, attributes)
    refute changeset.valid?
  end
end
