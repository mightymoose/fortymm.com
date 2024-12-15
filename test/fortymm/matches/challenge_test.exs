defmodule Fortymm.Matches.ChallengeTest do
  use Fortymm.DataCase, async: true

  import Fortymm.MatchesFixtures

  alias Fortymm.Matches.Challenge
  alias Fortymm.Repo

  test "is valid with valid attributes" do
    changeset = Challenge.changeset(%Challenge{}, valid_challenge_attributes())
    assert changeset.valid?
  end

  test "is invalid without a maximum number of games" do
    changeset =
      Challenge.changeset(
        %Challenge{},
        valid_challenge_attributes(%{maximum_number_of_games: nil})
      )

    refute changeset.valid?
  end

  test "is valid without a match" do
    changeset = Challenge.changeset(%Challenge{}, valid_challenge_attributes(%{match_id: 10}))
    assert changeset.valid?
  end

  test "is invalid with a maximum number of games not in Match.valid_match_lengths" do
    changeset =
      Challenge.changeset(
        %Challenge{},
        valid_challenge_attributes(%{maximum_number_of_games: 100})
      )

    refute changeset.valid?
  end

  test "is invalid with an invalid match" do
    assert {:error, changeset} =
             %Challenge{}
             |> Challenge.changeset(valid_challenge_attributes(%{match_id: 0}))
             |> Repo.insert()

    assert errors_on(changeset) == %{match_id: ["does not exist"]}
  end
end
