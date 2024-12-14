defmodule Fortymm.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_match_lengths [1, 3, 5, 7]

  def valid_match_lengths, do: @valid_match_lengths

  schema "matches" do
    field :status, Ecto.Enum, values: [:pending, :in_progress, :completed, :cancelled, :abandoned]
    field :maximum_number_of_games, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:status, :maximum_number_of_games])
    |> validate_required([:status, :maximum_number_of_games])
    |> validate_inclusion(:maximum_number_of_games, valid_match_lengths())
  end
end
