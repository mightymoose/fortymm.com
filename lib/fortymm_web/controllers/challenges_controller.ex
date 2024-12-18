defmodule FortymmWeb.ChallengesController do
  use FortymmWeb, :controller

  alias Fortymm.Matches

  def create(conn, %{"challenge" => challenge_params}) do
    current_user = conn.assigns.current_user

    challenge_params =
      challenge_params
      |> Map.put("created_by_id", current_user.id)

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
