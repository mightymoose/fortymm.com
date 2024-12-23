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
      |> Match.load_users()

    {:noreply, socket |> assign(match: match)}
  end

  def players(assigns) do
    [first_participant, second_participant] =
      assigns.match.match_participants
      |> Enum.map(& &1.user)
      |> Enum.sort_by(& &1.username)

    assigns =
      assigns
      |> assign(:first_player, first_participant)
      |> assign(:second_player, second_participant)

    ~H"""
    <h1 class="flex gap-x-3 text-base/7">
      <span class="font-semibold text-xl">{@first_player.username}</span>
      <span class="text-gray-600 text-lg">vs</span>
      <span class="font-semibold text-xl">{@second_player.username}</span>
    </h1>
    """
  end

  def status(assigns) do
    ~H"""
    <div class={"capitalize flex-none rounded-full px-2 py-1 text-xs font-medium ring-1 ring-inset #{status_styles(@match.status)}"}>
      {@match.status}
    </div>
    """
  end

  def game(assigns) do
    ~H"""
        <div>
        <div class="overflow-hidden rounded-lg bg-white bg-gray-50 border border-gray-200 h-40 flex flex-col">
            <div class="text-center px-4 py-5 font-medium text-gray-700">
            Game {@game_number}
          </div>
          <div class="text-center text-sm text-gray-500 grow flex justify-center items-center">
            Not Started
          </div>
        </div>
  </div>
  """

  end

  defp status_styles(:pending), do: "text-gray-400 ring-gray-400/30 bg-gray-400/10"
  defp status_styles(:in_progress), do: "text-green-400 ring-green-400/30 bg-green-400/10"
  defp status_styles(:completed), do: "text-blue-400 ring-blue-400/30 bg-blue-400/10"
  defp status_styles(:cancelled), do: "text-red-400 ring-red-400/30 bg-red-400/10"
  defp status_styles(:abandoned), do: "text-red-400 ring-red-400/30 bg-red-400/10"
end
