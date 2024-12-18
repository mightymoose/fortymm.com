defmodule Fortymm.Matches.Challenge do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Accounts.User
  alias Fortymm.Repo

  schema "challenges" do
    field :maximum_number_of_games, :integer
    field :match_id, :id

    belongs_to :created_by, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:maximum_number_of_games, :match_id, :created_by_id])
    |> validate_required([:maximum_number_of_games, :created_by_id])
    |> validate_inclusion(:maximum_number_of_games, Fortymm.Matches.Match.valid_match_lengths())
    |> foreign_key_constraint(:match_id)
    |> foreign_key_constraint(:created_by_id)
  end

  def load_creator(query) do
    Repo.preload(query, :created_by)
  end
end
