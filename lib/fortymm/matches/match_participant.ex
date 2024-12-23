defmodule Fortymm.Matches.MatchParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Accounts.User
  alias Fortymm.Matches.Match

  schema "match_participants" do
    belongs_to :user, User
    belongs_to :match, Match

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match_participant, attrs) do
    match_participant
    |> cast(attrs, [:user_id, :match_id])
    |> validate_required([:user_id, :match_id])
    |> unique_constraint([:user_id, :match_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:match_id)
  end
end
