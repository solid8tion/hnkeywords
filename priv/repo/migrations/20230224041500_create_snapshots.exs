defmodule Hnkeywords.Repo.Migrations.CreateSnapshots do
  use Ecto.Migration

  def change do
    create table(:snapshots) do
      add :name, :string

      timestamps()
    end

  end
end
