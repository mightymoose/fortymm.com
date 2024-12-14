defmodule FortymmWeb.DashboardLive.IndexTest do
  use FortymmWeb.ConnCase

  import Fortymm.AccountsFixtures

  describe "GET /dashboard" do
    test "when a user is not logged in, it should redirect to the login page", %{conn: conn} do
      conn = get(conn, ~p"/dashboard")
      assert redirected_to(conn, 302) == ~p"/users/log_in"
    end

    test "when a user is logged in, it should render the dashboard page", %{conn: conn} do
      conn =
        conn
        |> log_in_user(user_fixture())
        |> get(~p"/dashboard")

      assert html_response(conn, 200) =~ "Dashboard"
    end
  end
end
