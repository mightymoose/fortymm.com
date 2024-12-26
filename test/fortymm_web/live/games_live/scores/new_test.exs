defmodule FortymmWeb.GamesLive.Scores.NewTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Fortymm.MatchesFixtures
  import Fortymm.AccountsFixtures

  alias Fortymm.Matches
  alias Fortymm.Matches.Match

  describe "GET /matches/:id/games/:game_id/scores/new" do
    test "redirects to the match page if the user is not a participant", %{conn: conn} do
      challenge = challenge_fixture()
      other_user = user_fixture()
      user = user_fixture()

      {:ok, %{match: match, first_game: first_game}} =
        Matches.create_match_from_challenge(challenge, user)

      assert {:error, {:redirect, %{to: ~p"/matches/#{match.id}", flash: %{}}}} ==
               conn
               |> log_in_user(other_user)
               |> live(~p"/matches/#{match.id}/games/#{first_game.id}/scores/new")
    end

    test "redirects to the match page if no user is logged in", %{conn: conn} do
      match = match_fixture()

      assert {:error, {:redirect, %{to: ~p"/matches/#{match.id}", flash: %{}}}} ==
               live(conn, ~p"/matches/#{match.id}/games/456/scores/new")
    end

    test "redirects to the match page if the game does not belong to the match", %{conn: conn} do
      challenge = challenge_fixture()
      user = user_fixture()

      {:ok, %{first_game: first_game}} = Matches.create_match_from_challenge(challenge, user)

      assert {:error, {:redirect, %{to: ~p"/matches/#{first_game.match_id}", flash: %{}}}} ==
               conn
               |> log_in_user(user)
               |> live(~p"/matches/#{first_game.match_id}/games/123/scores/new")
    end

    test "redirects participants to the proposal verification page if the game has an unresolved score proposal",
         %{conn: conn} do
      challenge = challenge_fixture()
      user = user_fixture()

      {:ok, %{first_game: first_game, match: match}} =
        Matches.create_match_from_challenge(challenge, user)

      match = Match.load_participants(match)
      [first_participant, second_participant] = match.match_participants

      assert {:ok, lv, _html} =
               conn
               |> log_in_user(user)
               |> live(~p"/matches/#{first_game.match_id}/games/#{first_game.id}/scores/new")

      assert {:error, {:redirect, %{to: redirect_to}}} =
               lv
               |> form("#score-proposal-form",
                 scoring_proposal: %{
                   "scores" => %{
                     "0" => %{
                       "match_participant_id" => first_participant.id,
                       "score" => 12
                     },
                     "1" => %{
                       "match_participant_id" => second_participant.id,
                       "score" => 10
                     }
                   }
                 }
               )
               |> render_submit()

      assert {:error, {:redirect, %{to: ^redirect_to}}} =
               conn
               |> log_in_user(user)
               |> live(~p"/matches/#{first_game.match_id}/games/#{first_game.id}/scores/new")
    end

    test "redirects participants to the current game if this one has an accepted scoring proposal"
    test "redirects to the match page if the match has ended"

    test "shows the score proposal form when there is not one for the game", %{conn: conn} do
      challenge = challenge_fixture()
      user = user_fixture()

      {:ok, %{first_game: first_game}} = Matches.create_match_from_challenge(challenge, user)

      {:ok, _view, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/matches/#{first_game.match_id}/games/#{first_game.id}/scores/new")

      assert html =~ "Score Game"
    end

    test "redirects the user to the waiting for verification page when they propose a score", %{
      conn: conn
    } do
      challenge = challenge_fixture()
      user = user_fixture()

      {:ok, %{first_game: first_game, match: match}} =
        Matches.create_match_from_challenge(challenge, user)

      match = Match.load_participants(match)
      [first_participant, second_participant] = match.match_participants

      assert {:ok, lv, _html} =
               conn
               |> log_in_user(user)
               |> live(~p"/matches/#{first_game.match_id}/games/#{first_game.id}/scores/new")

      assert {:error, {:redirect, %{to: redirect_to}}} =
               lv
               |> form("#score-proposal-form",
                 scoring_proposal: %{
                   "scores" => %{
                     "0" => %{
                       "match_participant_id" => first_participant.id,
                       "score" => 12
                     },
                     "1" => %{
                       "match_participant_id" => second_participant.id,
                       "score" => 10
                     }
                   }
                 }
               )
               |> render_submit()

      route =
        ~r|^/matches/(?<id>\d+)/games/(?<game_id>\d+)/scores/(?<score_id>\d+)/verification/new$|

      assert %{"id" => match_id, "game_id" => game_id, "score_id" => score_id} =
               Regex.named_captures(route, redirect_to)

      assert "#{match.id}" == match_id
      assert "#{first_game.id}" == game_id

      scoring_proposal = Matches.get_scoring_proposal!(score_id)
      assert scoring_proposal.game_id == first_game.id
      assert scoring_proposal.created_by_id == user.id

      first_participant_id = first_participant.id
      second_participant_id = second_participant.id

      assert [
               %{match_participant_id: ^first_participant_id, score: 12},
               %{match_participant_id: ^second_participant_id, score: 10}
             ] = scoring_proposal.scores
    end

    test "redirects the opponent to the verification page when a score is proposed", %{conn: conn} do
      user = user_fixture()
      other_user = user_fixture()
      challenge = challenge_fixture(%{created_by_id: user.id})

      {:ok, %{match: match, first_game: first_game}} =
        Matches.create_match_from_challenge(challenge, other_user)

      match = Match.load_participants(match)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/matches/#{first_game.match_id}/games/#{first_game.id}/scores/new")

      {:ok, other_lv, _other_html} =
        conn
        |> log_in_user(other_user)
        |> live(~p"/matches/#{first_game.match_id}/games/#{first_game.id}/scores/new")

      [first_participant, second_participant] = match.match_participants

      assert {:error, {:redirect, %{to: redirect_to}}} =
               other_lv
               |> form("#score-proposal-form",
                 scoring_proposal: %{
                   "scores" => %{
                     "0" => %{
                       "match_participant_id" => first_participant.id,
                       "score" => 12
                     },
                     "1" => %{
                       "match_participant_id" => second_participant.id,
                       "score" => 10
                     }
                   }
                 }
               )
               |> render_submit()

      assert_redirect(lv, redirect_to)
    end

    test "notifies the user when the score is entered"
  end
end
