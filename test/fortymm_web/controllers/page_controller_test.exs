defmodule FortymmWeb.PageControllerTest do
  use FortymmWeb.ConnCase

  import Fortymm.AccountsFixtures

  describe "GET /" do
    test "when a user is logged in it should redirect to the dashboard", %{conn: conn} do
      conn =
        conn
        |> log_in_user(user_fixture())
        |> get(~p"/")

      assert redirected_to(conn, 302) == ~p"/dashboard"
    end

    test "when a user is not logged in it should show the landing page", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "FortyMM"
    end
  end
end
