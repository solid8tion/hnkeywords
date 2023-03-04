defmodule Hnkeywords.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :hn_id, :id, null: false
      add :title, :string, null: false
      add :rank, :integer, null: false
      add :url, :string
      add :snapshot_id, references (:snapshots)

      timestamps()
    end
  end
end
