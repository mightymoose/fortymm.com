defmodule Fortymm.Matches.ChallengeUpdatesTest do
  use Fortymm.DataCase, async: false

  alias Fortymm.Matches.ChallengeUpdates
  import Fortymm.MatchesFixtures

  describe "broadcast_challenge_accepted/1" do
    setup do
      challenge = challenge_fixture()
      %{challenge: challenge}
    end

    test "broadcasts a challenge_accepted message", %{challenge: challenge} do
      :ok = ChallengeUpdates.subscribe()

      assert :ok = ChallengeUpdates.broadcast_challenge_accepted(challenge)
      assert_receive {:challenge_accepted, ^challenge}
    end
  end
end
