defmodule Fortymm.Matches.ScoringUpdates do
  @topic "scoring_updates"

  alias Fortymm.PubSub

  def subscribe() do
    Phoenix.PubSub.subscribe(PubSub, @topic)
  end

  def broadcast_scoring_proposal_created(scoring_proposal) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {:scoring_proposal_created, scoring_proposal})
  end
end
