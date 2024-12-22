defmodule Fortymm.Matches.ChallengeUpdates do
  @topic "challenge_updates"

  def subscribe() do
    Phoenix.PubSub.subscribe(Fortymm.PubSub, @topic)
  end

  def broadcast_challenge_accepted(challenge) do
    Phoenix.PubSub.broadcast(
      Fortymm.PubSub,
      @topic,
      {:challenge_accepted, challenge}
    )
  end
end
