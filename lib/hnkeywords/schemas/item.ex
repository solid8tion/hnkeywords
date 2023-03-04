defmodule Hnkeywords.Schemas.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :hn_id, :id
    field :title, :string
    field :url, :string
    field :rank, :integer

    has_many :keywords, Hnkeywords.Schemas.Keyword
    belongs_to :snapshot, Hnkeywords.Schemas.Snapshot

    timestamps()
  end

  def changeset(item, params \\ %{}) do
    item
    |> cast(params, [:hn_id, :title, :url, :rank])
    |> validate_required([:hn_id, :title, :rank])
  end
end
