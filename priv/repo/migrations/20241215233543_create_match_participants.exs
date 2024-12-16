defmodule Fortymm.Repo.Migrations.CreateMatchParticipants do
  use Ecto.Migration

  def change do
    create table(:match_participants) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :match_id, references(:matches, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:match_participants, [:user_id])
    create index(:match_participants, [:match_id])
    create unique_index(:match_participants, [:user_id, :match_id])
  end
end
