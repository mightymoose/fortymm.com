defmodule FortymmWeb.ScoringProposalVerificationControllerTest do
  use FortymmWeb.ConnCase

  describe "new/2" do
    test "renders the new page", %{conn: conn} do
      conn = get(conn, ~p"/scoring-proposal-verification/new")

      response = html_response(conn, 200)
      assert response =~ "Scoring Proposal Verification"
    end
  end
end