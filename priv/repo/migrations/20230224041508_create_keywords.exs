defmodule Hnkeywords.Repo.Migrations.CreateKeywords do
  use Ecto.Migration

  def change do
    create table(:keywords) do
      add :item_id, references (:items)
      add :keyword, :string

      timestamps()
    end

  end
end
