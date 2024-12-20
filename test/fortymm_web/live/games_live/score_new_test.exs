defmodule FortymmWeb.GamesLive.ScoreNewTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "GET /matches/:id/games/:game_id/scores/new" do
    test "shows some scoring boilerplate", %{conn: conn} do
      {:ok, _view, html} =
        live(conn, ~p"/matches/1/games/2/scores/new")

      assert html =~ "Score Game"
    end
  end
end
