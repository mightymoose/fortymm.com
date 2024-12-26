defmodule FortymmWeb.ChallengesLive.Show do
  use FortymmWeb, :live_view

  alias Fortymm.Matches
  alias Fortymm.Matches.Match
  alias Fortymm.Matches.Challenge

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, uri, socket) do
    challenge = load_challenge!(id)
    socket = assign(socket, challenge: challenge, uri: uri)

    if Challenge.accepted?(challenge) do
      {:noreply, handle_accepted_challenge(socket, challenge)}
    else
      if connected?(socket) do
        Matches.subscribe_to_challenge_updates()
      end

      {:noreply, socket}
    end
  end

  def match_creator_view(assigns) do
    ~H"""
    <div class="grid md:grid-cols-2 grid-rows-2 gap-4">
      <div class="overflow-hidden rounded-lg bg-white shadow">
        <div class="px-4 py-5 sm:p-6">
          To invite someone to play, share this URL
          <div class="flex items-center gap-2">
            <input
              type="text"
              id="challenge_url"
              value={@uri}
              name="challenge_url"
              disabled
              class="block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6"
            />
            <button
              id="copy_challenge_url"
              data-to="#challenge_url"
              phx-hook="Copy"
              class="rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              <.icon name="hero-clipboard" class="h-5 w-5 block" />
              <.icon name="hero-check" class="h-5 w-5 hidden" />
            </button>
          </div>
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
        {@challenge.created_by.username} has invited you to play a best of {@challenge.maximum_number_of_games} match
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

  def handle_info({:challenge_accepted, challenge}, socket),
    do: {:noreply, handle_accepted_challenge(socket, challenge)}

  defp handle_accepted_challenge(socket, challenge) do
    current_user = socket.assigns.current_user
    this_challenge_id = socket.assigns.challenge.id

    case challenge.id do
      ^this_challenge_id ->
        match =
          challenge.match_id
          |> Matches.get_match!()
          |> Match.load_participants()

        push_navigate(socket, to: accepted_match_redirect(match, current_user))

      _ ->
        socket
    end
  end

  defp accepted_match_redirect(match, user) do
    case Enum.any?(match.match_participants, fn participant -> participant.user_id == user.id end) do
      true ->
        pending_game =
          match
          |> Match.load_games()
          |> Map.get(:games)
          |> Enum.find(fn game -> game.status == :pending end)

        redirect_for_game(match, pending_game)

      _ ->
        ~p"/matches/#{match.id}"
    end
  end

  defp redirect_for_game(match, nil), do: ~p"/matches/#{match.id}"
  defp redirect_for_game(match, game), do: ~p"/matches/#{match.id}/games/#{game.id}/scores/new"

  defp load_challenge!(id) do
    id
    |> Matches.get_challenge!()
    |> Challenge.load_creator()
  end
end
