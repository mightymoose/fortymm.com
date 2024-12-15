defmodule FortymmWeb.ChallengesControllerTest do
  use FortymmWeb.ConnCase

  alias Phoenix.Flash

  describe "POST /challenges" do
    setup [:register_and_log_in_user]

    test "redirects to login page when no user is logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log_out")
      challenge_params = %{"maximum_number_of_games" => 3}
      conn = post(conn, ~p"/challenges", challenge: challenge_params)
      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "redirects to challenge show page when data is valid", %{conn: conn} do
      challenge_params = %{
        "maximum_number_of_games" => 3
      }

      conn = post(conn, ~p"/challenges", challenge: challenge_params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/challenges/#{id}"
      assert Flash.get(conn.assigns.flash, :info) == "Challenge created successfully."
    end

    test "redirects to dashboard with error when data is invalid", %{conn: conn} do
      challenge_params = %{
        "maximum_number_of_games" => "invalid"
      }

      conn = post(conn, ~p"/challenges", challenge: challenge_params)

      assert redirected_to(conn) == ~p"/dashboard"
      assert Flash.get(conn.assigns.flash, :error) == "Error creating challenge."
    end
  end
end
