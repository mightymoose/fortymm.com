defmodule FortymmWeb.DashboardLive.Index do
  use FortymmWeb, :live_view

  alias Fortymm.Matches
  alias Fortymm.Matches.Challenge
  alias Fortymm.Matches.Match

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_challenges()}
  end

  def match_length_description(1), do: "to just 1 game"
  def match_length_description(length), do: "to a best of #{length} games"

  defp assign_challenges(socket) do
    new_match_forms =
      Match.valid_match_lengths()
      |> Enum.map(fn length ->
        changeset = Matches.change_challenge(%Challenge{}, %{maximum_number_of_games: length})
        to_form(changeset, as: "challenge")
      end)

    assign(socket, new_match_forms: new_match_forms)
  end
end
