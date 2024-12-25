defmodule Fortymm.Matches.ScoreTest do
  use Fortymm.DataCase, async: true

  alias Fortymm.Matches.Score
  import Fortymm.MatchesFixtures

  setup do
    %{valid_attrs: valid_score_attributes()}
  end

  test "is valid with valid attributes", %{valid_attrs: valid_attrs} do
    assert Score.changeset(%Score{}, valid_attrs).valid?
  end

  test "is invalid without a score", %{valid_attrs: valid_attrs} do
    refute Score.changeset(%Score{}, %{valid_attrs | score: nil}).valid?
  end

  test "is invalid without a match_participant_id", %{valid_attrs: valid_attrs} do
    refute Score.changeset(%Score{}, %{valid_attrs | match_participant_id: nil}).valid?
  end

  test "is invalid with an invalid score", %{valid_attrs: valid_attrs} do
    refute Score.changeset(%Score{}, %{valid_attrs | score: -1}).valid?
  end

  test "is invalid with an invalid match_participant_id", %{valid_attrs: valid_attrs} do
    refute Score.changeset(%Score{}, %{valid_attrs | match_participant_id: "invalid"}).valid?
  end
end
