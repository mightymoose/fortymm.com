defmodule FortymmWeb.MatchesLive.ShowTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Fortymm.MatchesFixtures

  describe "GET /matches/:id" do
    setup do
      %{match: match_fixture()}
    end

    test "renders match", %{conn: conn, match: match} do
      {:ok, _lv, html} = live(conn, ~p"/matches/#{match.id}")

      assert html =~ Atom.to_string(match.status)
      assert html =~ "#{match.maximum_number_of_games}"
    end
  end
end
