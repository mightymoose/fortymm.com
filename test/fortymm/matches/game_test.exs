defmodule Fortymm.Matches.GameTest do
  use Fortymm.DataCase, async: true

  import Fortymm.MatchesFixtures

  alias Fortymm.Matches
  alias Fortymm.Matches.Game

  describe "create_game/1" do
    test "creates a game with valid data" do
      match = match_fixture()
      valid_attrs = %{status: :pending, match_id: match.id}

      assert {:ok, %Game{} = game} = Matches.create_game(valid_attrs)
      assert game.status == :pending
      assert game.match_id == match.id
    end

    test "returns error changeset with invalid data" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_game(%{status: nil, match_id: nil})
    end

    test "returns error changeset with invalid match_id" do
      assert {:error, changeset} = Matches.create_game(%{status: :pending, match_id: 0})
      assert %{match_id: ["does not exist"]} = errors_on(changeset)
    end

    test "returns error changeset with invalid status" do
      match = match_fixture()
      assert {:error, changeset} = Matches.create_game(%{status: :invalid, match_id: match.id})
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end
  end
end
