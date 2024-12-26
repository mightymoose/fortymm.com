defmodule FortymmWeb.GamesLive.Scoring.New do
  use FortymmWeb, :live_view

  alias Fortymm.Matches.Match
  alias Fortymm.Matches
  alias Fortymm.Matches.ScoringProposal

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def score_label(match, %{id: current_user_id}, score) do
    match_participant_id = score[:match_participant_id].value
    match_participant = Enum.find(match.match_participants, &(&1.id == match_participant_id))

    case match_participant.user_id do
      ^current_user_id ->
        "Your score"

      _ ->
        "Score for #{match_participant.user.username}"
    end
  end

  def handle_event("save", %{"scoring_proposal" => scoring_proposal}, socket) do
    %{game_id: game_id, current_user: current_user, match: match} = socket.assigns

    result =
      Matches.create_scoring_proposal(%{
        "game_id" => game_id,
        "created_by_id" => current_user.id,
        "scores" => scoring_proposal["scores"]
      })

    case result do
      {:ok, scoring_proposal} ->
        {:noreply,
         redirect(socket,
           to:
             ~p"/matches/#{match.id}/games/#{game_id}/scores/#{scoring_proposal.id}/verification/new"
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, :score_proposal, changeset)}
    end
  end

  def handle_params(%{"match_id" => match_id, "game_id" => game_id}, _uri, socket) do
    if connected?(socket) do
      Matches.subscribe_to_scoring_updates()
    end

    socket
    |> assign(:game_id, game_id)
    |> load_match(match_id)
    |> redirect_to_match_without_user()
    |> ensure_game_belongs_to_match(game_id)
    |> redirect_to_match_without_participant()
    |> maybe_redirect_to_score_approval_page()
    |> assign_score_proposal_form(game_id)
  end

  defp maybe_redirect_to_score_approval_page({:noreply, socket}), do: {:noreply, socket}

  defp maybe_redirect_to_score_approval_page(socket) do
    %{game_id: game_id, match: match} = socket.assigns

    scoring_proposals = Matches.scoring_proposals_for_game(game_id)

    case scoring_proposals do
      [scoring_proposal] ->
        {:noreply,
         redirect(socket,
           to:
             ~p"/matches/#{match.id}/games/#{game_id}/scores/#{scoring_proposal.id}/verification/new"
         )}

      _ ->
        socket
    end
  end

  def handle_info({:scoring_proposal_created, scoring_proposal}, socket) do
    %{game_id: game_id} = socket.assigns

    case "#{scoring_proposal.game_id}" do
      ^game_id ->
        {:noreply, handle_score_created(socket, scoring_proposal)}

      _ ->
        {:noreply, socket}
    end
  end

  defp handle_score_created(socket, scoring_proposal) do
    %{match: match} = socket.assigns

    push_navigate(socket,
      to:
        ~p"/matches/#{match.id}/games/#{scoring_proposal.game_id}/scores/#{scoring_proposal.id}/verification/new"
    )
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

    scores = Enum.map(match.match_participants, &%{score: 10, match_participant_id: &1.id})

    score_proposal =
      %ScoringProposal{}
      |> Matches.change_scoring_proposal(%{
        game_id: game_id,
        created_by_id: current_user.id,
        scores: scores
      })

    {:noreply, assign(socket, :score_proposal, score_proposal)}
  end
end
