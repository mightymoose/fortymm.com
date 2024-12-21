defmodule FortymmWeb.ChallengesLive.ShowTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Fortymm.MatchesFixtures
  import Fortymm.AccountsFixtures

  alias Fortymm.Matches
  alias Fortymm.Matches.Match

  describe "GET /challenges/:id" do
    setup do
      user = user_fixture()
      challenge = challenge_fixture(%{created_by_id: user.id})
      %{challenge: challenge, user: user}
    end

    test "renders the challenge when the creator is logged in", %{
      conn: conn,
      challenge: challenge,
      user: user
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/challenges/#{challenge.id}")

      assert html =~ "To invite someone to play, give this URL"
    end

    test "renders the opponent view when the opponent is logged in", %{
      conn: conn,
      challenge: challenge,
      user: user
    } do
      opponent = user_fixture()

      {:ok, _lv, html} =
        conn
        |> log_in_user(opponent)
        |> live(~p"/challenges/#{challenge.id}")

      assert html =~ "#{user.username} has invited you to play"
    end

    test "redirects the opponent to the first game when they accept the challenge", %{
      conn: conn,
      challenge: challenge,
      user: user
    } do
      opponent = user_fixture()

      {:ok, lv, _html} =
        conn
        |> log_in_user(opponent)
        |> live(~p"/challenges/#{challenge.id}")

      assert {:error, {:live_redirect, %{to: redirect_url}}} =
               lv
               |> element(~s|button:fl-contains("Accept Challenge")|)
               |> render_click()

      assert [_, match_id, game_id] =
               Regex.run(~r|/matches/(\d+)/games/(\d+)/scores/new|, redirect_url)

      match =
        match_id
        |> Matches.get_match!()
        |> Match.load_participants()
        |> Match.load_games()

      challenge = Matches.get_challenge!(challenge.id)
      assert challenge.match_id == match.id
      assert challenge.accepted_by_id == opponent.id

      expected_user_id = user.id
      expected_opponent_id = opponent.id

      assert [%{user_id: ^expected_user_id}, %{user_id: ^expected_opponent_id}] =
               match.match_participants

      {expected_game_id, ""} = Integer.parse(game_id)
      {expected_match_id, ""} = Integer.parse(match_id)

      assert [%{id: ^expected_game_id, status: :pending, match_id: ^expected_match_id}] =
               match.games
    end

    test "redirects to login page when a user is not logged in", %{
      conn: conn,
      challenge: challenge
    } do
      conn = get(conn, ~p"/challenges/#{challenge.id}")
      assert redirected_to(conn, 302) == ~p"/users/log_in"
    end
  end
end
