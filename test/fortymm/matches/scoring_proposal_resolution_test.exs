defmodule Fortymm.Matches.ScoringProposalResolutionTest do
  use Fortymm.DataCase
  import Fortymm.MatchesFixtures

  alias Fortymm.Matches.ScoringProposalResolution
  alias Fortymm.Matches

  import Fortymm.MatchesFixtures

  test "is valid with valid attributes" do
    attrs = valid_scoring_proposal_resolution_attributes()
    assert ScoringProposalResolution.changeset(%ScoringProposalResolution{}, attrs).valid?
  end

  test "is invalid without a scoring proposal" do
    attrs = valid_scoring_proposal_resolution_attributes(%{scoring_proposal_id: nil})
    refute ScoringProposalResolution.changeset(%ScoringProposalResolution{}, attrs).valid?
  end

  test "is invalid without a created by" do
    attrs = valid_scoring_proposal_resolution_attributes(%{created_by_id: nil})
    refute ScoringProposalResolution.changeset(%ScoringProposalResolution{}, attrs).valid?
  end

  test "is invalid with a duplicate scoring proposal" do
    attrs = valid_scoring_proposal_resolution_attributes()
    {:ok, _scoring_proposal_resolution} = Matches.create_scoring_proposal_resolution(attrs)

    assert {:error, changeset} =
             Matches.create_scoring_proposal_resolution(attrs)

    refute changeset.valid?
    assert errors_on(changeset).scoring_proposal_id == ["has already been taken"]
  end

  test "is invalid with an invalid scoring proposal" do
    attrs = valid_scoring_proposal_resolution_attributes(%{scoring_proposal_id: 0})
    assert {:error, changeset} = Matches.create_scoring_proposal_resolution(attrs)

    assert errors_on(changeset).scoring_proposal_id == ["does not exist"]
  end

  test "is invalid with an invalid created by" do
    attrs = valid_scoring_proposal_resolution_attributes(%{created_by_id: 0})
    assert {:error, changeset} = Matches.create_scoring_proposal_resolution(attrs)

    assert errors_on(changeset).created_by_id == ["does not exist"]
  end
end
