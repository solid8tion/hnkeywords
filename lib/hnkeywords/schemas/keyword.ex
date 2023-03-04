defmodule Hnkeywords.Schemas.Keyword do
  use Ecto.Schema
  import Ecto.Changeset

  schema "keywords" do
    field :keyword, :string

    belongs_to :item, Hnkeywords.Schemas.Item

    timestamps()
  end

  def changeset(keyword, params \\ %{}) do
    keyword
    |> cast(params, [:keyword])
    |> validate_required([:keyword])
  end
end
