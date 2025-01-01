defmodule FortymmWeb.ChallengesLive.ShowTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Fortymm.MatchesFixtures
  import Fortymm.AccountsFixtures

  alias Fortymm.Matches
  alias Fortymm.Matches.Match
  alias Fortymm.Matches.Game
  alias Fortymm.Repo

  describe "GET /challenges/:id" do
    setup do
      user = user_fixture()
      challenge = challenge_fixture(%{created_by_id: user.id})
      %{challenge: challenge, user: user}
    end

    test "redirects the creator to the game page when there is a game in progress", %{
      conn: conn,
      challenge: challenge,
      user: user
    } do
      opponent = user_fixture()

      {:ok, %{match: %{id: match_id}, first_game: %{id: game_id}}} =
        Matches.create_match_from_challenge(challenge, opponent)

      expected_redirect_url = ~p"/matches/#{match_id}/games/#{game_id}/scores/new"

      assert {:error, {:live_redirect, %{to: ^expected_redirect_url}}} =
               conn
               |> log_in_user(user)
               |> live(~p"/challenges/#{challenge.id}")
    end

    test "redirects the creator to the match page when there is no game in progress", %{
      conn: conn,
      user: user,
      challenge: challenge
    } do
      opponent = user_fixture()

      {:ok, %{match: %{id: match_id}, first_game: game}} =
        Matches.create_match_from_challenge(challenge, opponent)

      game
      |> Game.changeset(%{status: :completed})
      |> Repo.update()

      expected_redirect_url = ~p"/matches/#{match_id}"

      assert {:error, {:live_redirect, %{to: ^expected_redirect_url}}} =
               conn
               |> log_in_user(user)
               |> live(~p"/challenges/#{challenge.id}")
    end

    test "redirects the opponent to the game page when there is a game in progress", %{
      conn: conn,
      challenge: challenge
    } do
      opponent = user_fixture()

      {:ok, %{match: %{id: match_id}, first_game: %{id: game_id}}} =
        Matches.create_match_from_challenge(challenge, opponent)

      expected_redirect_url = ~p"/matches/#{match_id}/games/#{game_id}/scores/new"

      assert {:error, {:live_redirect, %{to: ^expected_redirect_url}}} =
               conn
               |> log_in_user(opponent)
               |> live(~p"/challenges/#{challenge.id}")
    end

    test "redirects the opponent to the match page when there is no pending game", %{
      conn: conn,
      challenge: challenge
    } do
      opponent = user_fixture()

      {:ok, %{match: %{id: match_id}, first_game: game}} =
        Matches.create_match_from_challenge(challenge, opponent)

      game
      |> Game.changeset(%{status: :completed})
      |> Repo.update()

      expected_redirect_url = ~p"/matches/#{match_id}"

      assert {:error, {:live_redirect, %{to: ^expected_redirect_url}}} =
               conn
               |> log_in_user(opponent)
               |> live(~p"/challenges/#{challenge.id}")
    end

    test "redirects other users to the match page when the challenge has already been accepted",
         %{
           conn: conn,
           challenge: challenge
         } do
      opponent = user_fixture()
      other_user = user_fixture()

      {:ok, %{match: %{id: match_id}}} = Matches.create_match_from_challenge(challenge, opponent)

      assert {:error, {:live_redirect, %{to: redirect_url}}} =
               conn
               |> log_in_user(other_user)
               |> live(~p"/challenges/#{challenge.id}")

      assert redirect_url == ~p"/matches/#{match_id}"
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

      assert html =~ "To invite someone to play, share this URL"
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

    test "redirects the creator to the first game when the opponent accepts the challenge", %{
      conn: conn,
      challenge: challenge,
      user: user
    } do
      opponent = user_fixture()

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/challenges/#{challenge.id}")

      {:ok, opponent_lv, _html} =
        conn
        |> log_in_user(opponent)
        |> live(~p"/challenges/#{challenge.id}")

      assert {:error, {:live_redirect, %{to: redirect_url}}} =
               opponent_lv
               |> element(~s|button:fl-contains("Accept Challenge")|)
               |> render_click()

      assert_redirect(lv, redirect_url)
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

      assert_redirected(lv, redirect_url)

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

      assert [%{id: ^expected_game_id, status: :in_progress, match_id: ^expected_match_id}] =
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
