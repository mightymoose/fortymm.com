defmodule FortymmWeb.ChallengesLive.Show do
  use FortymmWeb, :live_view

  alias Fortymm.Matches

  def mount(%{"id" => id}, _session, socket) do
    challenge = Matches.get_challenge!(id)
    {:ok, assign(socket, challenge: challenge)}
  end
end
