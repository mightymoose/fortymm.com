defmodule FortymmWeb.ChallengesController do
  use FortymmWeb, :controller

  alias Fortymm.Matches

  def create(conn, %{"challenge" => challenge_params}) do
    case Matches.create_challenge(challenge_params) do
      {:ok, challenge} ->
        conn
        |> put_flash(:info, "Challenge created successfully.")
        |> redirect(to: ~p"/challenges/#{challenge.id}")

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Error creating challenge.")
        |> redirect(to: ~p"/dashboard")
    end
  end
end
