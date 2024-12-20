defmodule FortymmWeb.MatchesLive.Show do
  use FortymmWeb, :live_view

  alias Fortymm.Matches
  alias Fortymm.Matches.Match

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    match =
      id
      |> Matches.get_match!()
      |> Match.load_games()

    {:noreply, socket |> assign(match: match)}
  end
end
