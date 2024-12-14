defmodule Fortymm.MatchesTest do
  use Fortymm.DataCase

  alias Fortymm.Matches

  describe "matches" do
    alias Fortymm.Matches.Match

    import Fortymm.MatchesFixtures

    @invalid_attrs %{status: nil, maximum_number_of_games: nil}

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Matches.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Matches.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      valid_attrs = valid_match_attributes()
      assert {:ok, %Match{} = match} = Matches.create_match(valid_attrs)
      assert match.status == valid_attrs.status
      assert match.maximum_number_of_games == valid_attrs.maximum_number_of_games
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()
      update_attrs = valid_match_attributes() |> Map.put(:status, :completed)

      assert {:ok, %Match{} = match} = Matches.update_match(match, update_attrs)
      assert match.status == update_attrs.status
      assert match.maximum_number_of_games == update_attrs.maximum_number_of_games
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      assert {:error, %Ecto.Changeset{}} = Matches.update_match(match, @invalid_attrs)
      assert match == Matches.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = Matches.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> Matches.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = Matches.change_match(match)
    end
  end
end
