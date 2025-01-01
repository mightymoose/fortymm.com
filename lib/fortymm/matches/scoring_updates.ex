defmodule Fortymm.Matches.ScoringUpdates do
  @topic "scoring_updates"

  alias Fortymm.PubSub

  def subscribe() do
    Phoenix.PubSub.subscribe(PubSub, @topic)
  end

  def broadcast_scoring_proposal_created(scoring_proposal) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {:scoring_proposal_created, scoring_proposal})
  end

  def broadcast_scoring_proposal_approved(details) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {:scoring_proposal_approved, details})
  end

  def broadcast_scoring_proposal_rejected(game) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {:scoring_proposal_rejected, game})
  end
end
