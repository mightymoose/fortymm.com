defmodule FortymmWeb.ChallengesLive.Show do
  use FortymmWeb, :live_view

  alias Fortymm.Matches
  alias Fortymm.Matches.Challenge

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, uri, socket) do
    challenge = load_challenge!(id)
    {:noreply, assign(socket, challenge: challenge, uri: uri)}
  end

  def match_creator_view(assigns) do
    ~H"""
    <div class="grid md:grid-cols-2 grid-rows-2 gap-4">
      <div class="overflow-hidden rounded-lg bg-white shadow">
        <div class="px-4 py-5 sm:p-6">
          To invite someone to play, give this URL
        </div>
      </div>

      <div class="overflow-hidden rounded-lg bg-white shadow">
        <div class="px-4 py-5 sm:p-6">
          Or let your opponent scan this QR code <.qr_code text={@uri} />
        </div>
      </div>
    </div>
    """
  end

  def opponent_view(assigns) do
    ~H"""
    <div class="grid md:grid-cols-2 grid-rows-2 gap-4">
      <div>
        {@challenge.created_by.username} has invited you to play
        <button
          phx-click="accept_challenge"
          class="mt-4 rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          Accept Challenge
        </button>
      </div>
    </div>
    """
  end

  def handle_event("accept_challenge", _params, socket) do
    with {:ok, %{match: match, first_game: first_game}} <-
           Matches.create_match_from_challenge(
             socket.assigns.challenge,
             socket.assigns.current_user
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "Challenge accepted! Let's play!")
       |> push_navigate(to: ~p"/matches/#{match.id}/games/#{first_game.id}/scores/new")}
    else
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong accepting the challenge. Please try again.")}
    end
  end

  defp load_challenge!(id) do
    id
    |> Matches.get_challenge!()
    |> Challenge.load_creator()
  end
end
