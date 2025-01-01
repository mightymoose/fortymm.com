defmodule Fortymm.MatchesTest do
  use Fortymm.DataCase

  alias Fortymm.Matches

  describe "scoring_proposal_resolutions" do
    import Fortymm.MatchesFixtures

    test "create_scoring_proposal_resolution/1 with valid data creates a scoring proposal resolution" do
      attrs = valid_scoring_proposal_resolution_attributes()

      assert {:ok, _scoring_proposal_resolution} =
               Matches.create_scoring_proposal_resolution(attrs)
    end

    test "create_scoring_proposal_resolution/1 with invalid data returns error changeset" do
      attrs = valid_scoring_proposal_resolution_attributes(%{scoring_proposal_id: 0})
      assert {:error, changeset} = Matches.create_scoring_proposal_resolution(attrs)
      assert errors_on(changeset).scoring_proposal_id == ["does not exist"]
    end
  end

  describe "scoring_proposals" do
    import Fortymm.MatchesFixtures
    import Fortymm.AccountsFixtures
    alias Fortymm.Matches.Match

    test "create_scoring_proposal/1 with valid data broadcasts a scoring_proposal_created message" do
      Matches.subscribe_to_scoring_updates()

      user = user_fixture()
      challenge = challenge_fixture()

      {:ok, %{match: match, first_game: first_game}} =
        Matches.create_match_from_challenge(challenge, user)

      match = Match.load_participants(match)
      [first_participant, second_participant] = match.match_participants

      assert {:ok, scoring_proposal} =
               Matches.create_scoring_proposal(%{
                 game_id: first_game.id,
                 created_by_id: user.id,
                 scores: [
                   %{match_participant_id: first_participant.id, score: 10},
                   %{match_participant_id: second_participant.id, score: 12}
                 ]
               })

      assert_receive {:scoring_proposal_created, ^scoring_proposal}
    end

    test "create_scoring_proposal/1 with valid data creates a scoring proposal" do
      first_user = user_fixture()
      second_user = user_fixture()

      challenge =
        challenge_fixture(%{
          created_by_id: first_user.id,
          maximum_number_of_games: 7
        })

      {:ok, %{match: match, first_game: first_game}} =
        Matches.create_match_from_challenge(challenge, second_user)

      match = Match.load_participants(match)
      [first_participant, second_participant] = match.match_participants

      assert {:ok, scoring_proposal} =
               Matches.create_scoring_proposal(%{
                 game_id: first_game.id,
                 created_by_id: first_user.id,
                 scores: [
                   %{match_participant_id: first_participant.id, score: 10},
                   %{match_participant_id: second_participant.id, score: 12}
                 ]
               })

      assert scoring_proposal.created_by_id == first_user.id
      assert scoring_proposal.game_id == first_game.id
      assert length(scoring_proposal.scores) == 2
      [first_score, second_score] = scoring_proposal.scores

      assert first_score.match_participant_id == first_participant.id
      assert first_score.score == 10
      assert second_score.match_participant_id == second_participant.id
      assert second_score.score == 12
    end
  end

  describe "match_participants" do
    import Fortymm.MatchesFixtures

    alias Fortymm.Matches.MatchParticipant

    @invalid_attrs %{user_id: nil, match_id: nil}

    test "create_match_participant/1 with valid data creates a match participant" do
      valid_attrs = valid_match_participant_attributes()

      assert {:ok, %MatchParticipant{} = match_participant} =
               Matches.create_match_participant(valid_attrs)

      assert match_participant.user_id == valid_attrs.user_id
      assert match_participant.match_id == valid_attrs.match_id
    end

    test "create_match_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_match_participant(@invalid_attrs)
    end
  end

  describe "challenges" do
    alias Fortymm.Matches.Challenge

    import Fortymm.MatchesFixtures

    @invalid_attrs %{maximum_number_of_games: nil, match_id: nil}

    test "get_challenge!/1 returns the challenge with given id" do
      challenge = challenge_fixture()
      assert Matches.get_challenge!(challenge.id) == challenge
    end

    test "create_challenge/1 with valid data creates a challenge" do
      valid_attrs = valid_challenge_attributes()
      assert {:ok, %Challenge{} = challenge} = Matches.create_challenge(valid_attrs)
      assert challenge.match_id == valid_attrs.match_id
      assert challenge.maximum_number_of_games == valid_attrs.maximum_number_of_games
    end

    test "create_challenge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_challenge(@invalid_attrs)
    end

    test "change_challenge/1 returns a challenge changeset" do
      challenge = challenge_fixture()
      assert %Ecto.Changeset{} = Matches.change_challenge(challenge)
    end
  end

  describe "matches" do
    alias Fortymm.Matches.Match

    import Fortymm.MatchesFixtures
    import Fortymm.AccountsFixtures

    @invalid_attrs %{status: nil, maximum_number_of_games: nil}

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Matches.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Matches.get_match!(match.id) == match
    end

    test "create_match_from_challenge/2 creates a match from a challenge" do
      challenge = challenge_fixture()
      user = user_fixture()

      assert {:ok, %{first_game: first_game, match: match, updated_challenge: updated_challenge}} =
               Matches.create_match_from_challenge(challenge, user)

      assert match.status == :pending
      assert match.maximum_number_of_games == challenge.maximum_number_of_games

      assert first_game.match_id == match.id
      assert first_game.status == :pending

      assert updated_challenge.match_id == match.id
      assert updated_challenge.accepted_by_id == user.id
    end

    test "create_match_from_challenge/2 broadcasts a challenge_accepted message" do
      challenge = challenge_fixture()
      user = user_fixture()

      :ok = Matches.subscribe_to_challenge_updates()

      assert {:ok, %{updated_challenge: updated_challenge}} =
               Matches.create_match_from_challenge(challenge, user)

      assert_receive {:challenge_accepted, ^updated_challenge}
    end

    test "create_match/1 with valid data creates a match" do
      valid_attrs = valid_match_attributes()
      assert {:ok, %Match{} = match} = Matches.create_match(valid_attrs)
      assert match.status == valid_attrs.status
      assert match.maximum_number_of_games == valid_attrs.maximum_number_of_games
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()
      update_attrs = valid_match_attributes() |> Map.put(:status, :completed)

      assert {:ok, %Match{} = match} = Matches.update_match(match, update_attrs)
      assert match.status == update_attrs.status
      assert match.maximum_number_of_games == update_attrs.maximum_number_of_games
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      assert {:error, %Ecto.Changeset{}} = Matches.update_match(match, @invalid_attrs)
      assert match == Matches.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = Matches.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> Matches.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = Matches.change_match(match)
    end
  end
end
