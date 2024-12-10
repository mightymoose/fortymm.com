defmodule FortymmWeb.DashboardLive.IndexTest do
  use FortymmWeb.ConnCase

  test "GET /dashboard", %{conn: conn} do
    conn = get(conn, ~p"/dashboard")
    assert html_response(conn, 200) =~ "Dashboard"
  end
end
