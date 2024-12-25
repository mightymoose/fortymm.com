defmodule FortymmWeb.GamesLive.Scores.NewTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Fortymm.MatchesFixtures
  import Fortymm.AccountsFixtures

  alias Fortymm.Matches

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

    test "redirects participants to the proposal verification page if the game has an unresolved score proposal"
    test "redirects participants to the current game if this one has an accepted proposal"
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

    test "redirects the user to the waiting for verification page when they propose a score"
    test "redirects the opponent to the verification page when a score is proposed"
  end
end
