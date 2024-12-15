defmodule Fortymm.Matches.Challenge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "challenges" do
    field :maximum_number_of_games, :integer
    field :match_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:maximum_number_of_games, :match_id])
    |> validate_required([:maximum_number_of_games])
    |> validate_inclusion(:maximum_number_of_games, Fortymm.Matches.Match.valid_match_lengths())
    |> foreign_key_constraint(:match_id)
  end
end
