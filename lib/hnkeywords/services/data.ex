defmodule Hnkeywords.Services.Data do

  alias Hnkeywords.Schemas.{Snapshot, Item, Keyword}
  alias Hnkeywords.Repo
  alias Ecto.Changeset
  import Ecto.Query

  def save(snapshot_name, params) do
    {:ok, snapshot_obj} = create_snapshot(%{name: snapshot_name})
    Enum.each(params, &parse_item(&1, snapshot_obj))
  end

  def fetch_keywords(days, limit \\ 10) do
    query = from k in Keyword,
      group_by: k.keyword, 
      select: [fragment("count(?) as count", k.id), k.keyword],
      limit: ^limit,
      order_by: [desc: fragment("count")],
      where: k.inserted_at > ago(^days, "day")
    Repo.all(query)
  end

  defp parse_item({keywords, {hn_id, title, url, rank}}, snapshot) do
    {:ok, item_obj} = create_item(%{hn_id: hn_id, title: title, rank: rank, url: url}, snapshot)
    Enum.each(keywords, &parse_keyword(&1, item_obj))
  end

  defp parse_keyword(keyword, item) do
    {:ok, _ } = create_keyword(%{keyword: String.trim(keyword)}, item)
  end

  defp create_snapshot(params) do
    %Snapshot{}
    |> Snapshot.changeset(params)
    |> Repo.insert()
  end

  defp create_item(params, snapshot) do
    %Item{}
    |> Item.changeset(params)
    |> Changeset.put_assoc(:snapshot, snapshot)
    |> Repo.insert()
  end

  defp create_keyword(params, item) do
    %Keyword{}
    |> Keyword.changeset(params)
    |> Changeset.put_assoc(:item, item)
    |> Repo.insert()
  end
  
end