defmodule Hnkeywords.Services.Hn do
  @item_base_url "https://hacker-news.firebaseio.com/v0/item/"
  @topstories_url "https://hacker-news.firebaseio.com/v0/topstories.json"
  
  def topstories do
    case HTTPoison.get(@topstories_url) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Jason.decode!(body) }
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found }
      {:ok, %HTTPoison.Error{reason: reason}} ->
        {:error, reason }
    end
  end

  def iterate({item_id, index}) do
    fetch_item(item_id)
    |> format_results(index)
  end

  defp format_results({:ok, %{ "id" => hn_id, "title" => title, "url" => url }}, index) do
    {hn_id, title, url, index}
  end  

  defp format_results({:ok, %{ "id" => hn_id, "title" => title }}, index) do
    {hn_id, title, "https://news.ycombinator.com/item?id=#{hn_id}", index}
  end  

  defp fetch_item(item_id) do
    case HTTPoison.get(item_url(item_id)) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Jason.decode!(body) }
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found }
      {:ok, %HTTPoison.Error{reason: reason}} ->
        {:error, reason }
    end
  end

  defp item_url(item_id) do
    "#{@item_base_url}#{item_id}.json"
  end
end