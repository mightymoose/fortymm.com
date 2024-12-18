defmodule FortymmWeb.ChallengesLive.ShowTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Fortymm.MatchesFixtures
  import Fortymm.AccountsFixtures

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

    test "redirects to login page when a user is not logged in", %{
      conn: conn,
      challenge: challenge
    } do
      conn = get(conn, ~p"/challenges/#{challenge.id}")
      assert redirected_to(conn, 302) == ~p"/users/log_in"
    end
  end
end
