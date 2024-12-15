defmodule FortymmWeb.ChallengesLive.ShowTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Fortymm.MatchesFixtures
  import Fortymm.AccountsFixtures

  describe "GET /challenges/:id" do
    setup do
      %{challenge: challenge_fixture()}
    end

    test "renders challenge when a user is logged in", %{conn: conn, challenge: challenge} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/challenges/#{challenge.id}")

      assert html =~ "#{challenge.maximum_number_of_games}"
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
