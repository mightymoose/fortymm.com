defmodule Fortymm.Matches.MatchParticipantTest do
  use Fortymm.DataCase
  import Fortymm.MatchesFixtures

  alias Fortymm.Matches.MatchParticipant
  alias Fortymm.Matches

  test "is valid with valid attributes" do
    changeset =
      MatchParticipant.changeset(%MatchParticipant{}, valid_match_participant_attributes())

    assert changeset.valid?
  end

  test "is invlalid without a user_id" do
    attributes = valid_match_participant_attributes(%{user_id: nil})
    changeset = MatchParticipant.changeset(%MatchParticipant{}, attributes)
    refute changeset.valid?
  end

  test "is invlalid without a match_id" do
    attributes = valid_match_participant_attributes(%{match_id: nil})
    changeset = MatchParticipant.changeset(%MatchParticipant{}, attributes)
    refute changeset.valid?
  end

  test "is invlalid with a duplicate user_id and match_id" do
    match_participant = match_participant_fixture()

    attributes =
      valid_match_participant_attributes(%{
        user_id: match_participant.user_id,
        match_id: match_participant.match_id
      })

    assert {:error, changeset} = Matches.create_match_participant(attributes)

    assert errors_on(changeset).user_id == ["has already been taken"]
  end
end
