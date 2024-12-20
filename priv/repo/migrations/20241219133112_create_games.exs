defmodule Fortymm.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :status, :string, null: false
      add :match_id, references(:matches, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:games, [:match_id])
  end
end
