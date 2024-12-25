defmodule FortymmWeb.ScoringProposalVerificationController do
  use FortymmWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end
end
