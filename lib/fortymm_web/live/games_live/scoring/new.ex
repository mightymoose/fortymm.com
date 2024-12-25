defmodule FortymmWeb.GamesLive.Scoring.New do
  use FortymmWeb, :live_view

  alias Fortymm.Matches.Match
  alias Fortymm.Matches
  alias Fortymm.Matches.ScoringProposal

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def score_label(match, %{id: current_user_id}, score) do
    participant_id = score[:participant_id].value
    participant = Enum.find(match.match_participants, &(&1.id == participant_id))

    case participant.user_id do
      ^current_user_id ->
        "Your score"

      _ ->
        match_participant =
          match.match_participants
          |> Enum.find(&(&1.id == score[:participant_id].value))

        "Score for #{match_participant.user.username}"
    end
  end

  def handle_params(%{"match_id" => match_id, "game_id" => game_id}, _uri, socket) do
    socket
    |> load_match(match_id)
    |> redirect_to_match_without_user()
    |> ensure_game_belongs_to_match(game_id)
    |> redirect_to_match_without_participant()
    |> assign_score_proposal_form(game_id)
  end

  defp redirect_to_match_without_user(socket) do
    case socket.assigns.current_user do
      nil ->
        %{match: match} = socket.assigns
        {:noreply, redirect(socket, to: ~p"/matches/#{match.id}")}

      _ ->
        socket
    end
  end

  defp load_match({:noreply, socket}, _match_id), do: {:noreply, socket}

  defp load_match(socket, match_id) do
    match =
      match_id
      |> Matches.get_match!()
      |> Match.load_games()
      |> Match.load_participants()
      |> Match.load_users()

    assign(socket, :match, match)
  end

  defp ensure_game_belongs_to_match({:noreply, socket}, _game_id), do: {:noreply, socket}

  defp ensure_game_belongs_to_match(socket, game_id) do
    %{match: match} = socket.assigns

    case Enum.find(match.games, fn game -> "#{game.id}" == game_id end) do
      nil ->
        redirect_to_match_page(socket)

      _ ->
        socket
    end
  end

  defp redirect_to_match_without_participant({:noreply, socket}), do: {:noreply, socket}

  defp redirect_to_match_without_participant(socket) do
    %{current_user: current_user, match: match} = socket.assigns
    [first_participant, second_participant] = match.match_participants

    if current_user.id in [first_participant.user_id, second_participant.user_id] do
      socket
    else
      redirect_to_match_page(socket)
    end
  end

  defp redirect_to_match_page(socket) do
    %{match: match} = socket.assigns
    {:noreply, redirect(socket, to: ~p"/matches/#{match.id}")}
  end

  defp assign_score_proposal_form({:noreply, socket}, _game_id), do: {:noreply, socket}

  defp assign_score_proposal_form(socket, game_id) do
    %{match: match, current_user: current_user} = socket.assigns

    scores = Enum.map(match.match_participants, &%{score: 0, participant_id: &1.id})

    score_proposal =
      %ScoringProposal{}
      |> Matches.change_scoring_proposal(%{
        game_id: game_id,
        created_by_id: current_user.id,
        scores: scores
      })
      |> to_form()

    {:noreply, assign(socket, :score_proposal, score_proposal)}
  end
end
