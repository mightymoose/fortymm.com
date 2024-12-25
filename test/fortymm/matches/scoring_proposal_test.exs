defmodule Fortymm.Matches.ScoringProposalTest do
  use Fortymm.DataCase, async: true

  alias Fortymm.Matches.ScoringProposal
  import Fortymm.MatchesFixtures

  describe "changeset/2" do
    test "is valid with valid attributes" do
      attrs = valid_scoring_proposal_attributes()
      assert {:ok, _} = ScoringProposal.changeset(%ScoringProposal{}, attrs) |> Repo.insert()
    end

    test "is invalid without a game_id" do
      attrs = valid_scoring_proposal_attributes(%{game_id: nil})
      refute ScoringProposal.changeset(%ScoringProposal{}, attrs).valid?
    end

    test "is invalid without a created_by_id" do
      attrs = valid_scoring_proposal_attributes(%{created_by_id: nil})
      refute ScoringProposal.changeset(%ScoringProposal{}, attrs).valid?
    end

    test "is invalid with an invalid game_id" do
      attrs = valid_scoring_proposal_attributes(%{game_id: "invalid"})

      assert {:error, %Ecto.Changeset{}} =
               ScoringProposal.changeset(%ScoringProposal{}, attrs) |> Repo.insert()
    end

    test "is invalid if there are not two scores" do
      attrs = valid_scoring_proposal_attributes(%{scores: []})
      refute ScoringProposal.changeset(%ScoringProposal{}, attrs).valid?
    end

    test "is invalid if nobody has won" do
      proposal = valid_scoring_proposal_attributes()
      [first_score, second_score] = proposal.scores
      scores = [%{first_score | score: 10}, %{second_score | score: 10}]
      attrs = valid_scoring_proposal_attributes(%{scores: scores})

      refute ScoringProposal.changeset(%ScoringProposal{}, attrs).valid?
    end

    test "is invalid if someone has scored more than 11 points without going to deuce" do
      proposal = valid_scoring_proposal_attributes()
      [first_score, second_score] = proposal.scores
      scores = [%{first_score | score: 12}, %{second_score | score: 9}]
      attrs = valid_scoring_proposal_attributes(%{scores: scores})

      refute ScoringProposal.changeset(%ScoringProposal{}, attrs).valid?
    end

    test "is invalid with an invalid created_by_id" do
      attrs = valid_scoring_proposal_attributes(%{created_by_id: "invalid"})

      assert {:error, %Ecto.Changeset{}} =
               ScoringProposal.changeset(%ScoringProposal{}, attrs) |> Repo.insert()
    end
  end
end
