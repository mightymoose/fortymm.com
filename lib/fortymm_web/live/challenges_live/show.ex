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
      {@challenge_creator.username} has invited you to play
    </div>
    """
  end

  defp load_challenge!(id) do
    id
    |> Matches.get_challenge!()
    |> Challenge.load_creator()
  end
end
