defmodule FortymmWeb.MatchesLive.Show do
  use FortymmWeb, :live_view

  alias Fortymm.Matches

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    match = Matches.get_match!(id)
    {:noreply, socket |> assign(match: match)}
  end
end
