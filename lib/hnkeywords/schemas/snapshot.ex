defmodule Hnkeywords.Schemas.Snapshot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "snapshots" do
    field :name, :string

    has_many :items, Hnkeywords.Schemas.Item
    
    timestamps()
  end

  def changeset(name, params \\ %{}) do
    name
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
