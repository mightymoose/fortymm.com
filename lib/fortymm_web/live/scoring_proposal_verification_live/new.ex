defmodule FortymmWeb.ScoringProposalVerificationLive.New do
  use FortymmWeb, :live_view

  alias Fortymm.Matches
  alias Fortymm.Matches.Match

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("accept", _params, socket) do
    %{scoring_proposal: scoring_proposal, current_user: current_user} = socket.assigns

    {:ok, _scoring_proposal_resolution} =
      Matches.create_scoring_proposal_resolution(%{
        accepted: true,
        created_by_id: current_user.id,
        scoring_proposal_id: scoring_proposal.id
      })

    {:noreply, socket}
  end

  def handle_event("reject", _params, socket) do
    %{scoring_proposal: scoring_proposal, current_user: current_user, match: match} =
      socket.assigns

    {:ok, _scoring_proposal_resolution} =
      Matches.create_scoring_proposal_resolution(%{
        accepted: false,
        created_by_id: current_user.id,
        scoring_proposal_id: scoring_proposal.id
      })

    {:noreply,
     redirect(socket, to: ~p"/matches/#{match.id}/games/#{scoring_proposal.game_id}/scores/new")}
  end

  def score_description(assigns) do
    scores = assigns.scoring_proposal.scores
    my_score = Enum.find(scores, &(&1.match_participant.user_id == assigns.user.id))
    opponent_score = Enum.find(scores, &(&1.match_participant.user_id != assigns.user.id))

    description = if my_score.score > opponent_score.score, do: "won", else: "lost"

    assigns =
      assigns
      |> assign(:description, description)
      |> assign(:my_score, my_score)
      |> assign(:opponent_score, opponent_score)

    ~H"""
    According to {@scoring_proposal.created_by.username} you {@description} the game {@my_score.score} to {@opponent_score.score}
    """
  end

  def handle_params(
        %{"match_id" => match_id, "game_id" => game_id, "score_id" => score_id},
        _uri,
        socket
      ) do
    socket
    |> assign_match(match_id)
    |> assign_scoring_proposal(score_id)
    |> validate_game_id(game_id)
    |> validate_score_id(score_id)
    |> ensure_match_participant()
    |> ensure_latest_scoring_proposal(score_id)
    |> ensure_proposal_not_resolved(score_id)
  end

  defp assign_scoring_proposal(socket, score_id) do
    %{match: match} = socket.assigns

    score =
      match.games
      |> Enum.flat_map(& &1.scoring_proposals)
      |> Enum.find(&("#{&1.id}" == score_id))

    assign(socket, :scoring_proposal, score)
  end

  defp ensure_proposal_not_resolved({:noreply, socket}, _score_id), do: {:noreply, socket}

  defp ensure_proposal_not_resolved(socket, score_id) do
    %{match: match} = socket.assigns

    score =
      match
      |> Map.get(:games)
      |> Enum.flat_map(& &1.scoring_proposals)
      |> Enum.find(&("#{&1.id}" == score_id))

    case score.scoring_proposal_resolution do
      nil ->
        {:noreply, socket}

      _ ->
        {:noreply,
         redirect(socket, to: ~p"/matches/#{match.id}/games/#{score.game_id}/scores/new")}
    end
  end

  defp validate_score_id(socket, score_id) do
    %{match: match} = socket.assigns

    score =
      match.games |> Enum.flat_map(& &1.scoring_proposals) |> Enum.find(&("#{&1.id}" == score_id))

    case score do
      nil -> {:noreply, redirect(socket, to: ~p"/matches/#{match.id}")}
      _ -> socket
    end
  end

  defp validate_game_id(socket, game_id) do
    %{match: match} = socket.assigns

    game = match.games |> Enum.find(&("#{&1.id}" == game_id))

    case game do
      nil -> {:noreply, redirect(socket, to: ~p"/matches/#{match.id}")}
      _ -> socket
    end

    socket
  end

  defp assign_match(socket, match_id) do
    match =
      match_id
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Match.load_scoring()

    assign(socket, :match, match)
  end

  defp ensure_match_participant({:noreply, socket}), do: {:noreply, socket}

  defp ensure_match_participant(socket) do
    %{current_user: current_user, match: match} = socket.assigns
    user_participant = match.match_participants |> Enum.find(&(&1.user_id == current_user.id))

    case user_participant do
      nil -> {:noreply, redirect(socket, to: ~p"/matches/#{match.id}")}
      _ -> socket
    end
  end

  defp ensure_latest_scoring_proposal({:noreply, socket}, _score_id), do: {:noreply, socket}

  defp ensure_latest_scoring_proposal(socket, score_id) do
    %{match: match} = socket.assigns

    latest_score =
      match.games
      |> Enum.flat_map(& &1.scoring_proposals)
      |> Enum.max_by(& &1.id)

    case "#{latest_score.id}" do
      ^score_id ->
        socket

      _ ->
        {:noreply,
         redirect(socket,
           to:
             ~p"/matches/#{match.id}/games/#{latest_score.game_id}/scores/#{latest_score.id}/verification/new"
         )}
    end
  end
end
