defmodule Hnkeywords do
  alias Hnkeywords.Services
  
  @openai_timeout 25_000
  @await_timeout 10_000

  def process do
    view_stories()
    |> extract_keywords() 
    |> save_keywords()
  end

  def runall() do
    topstories = process()
    topkeywords = fetch()
    datetime = DateTime.utc_now() |> Calendar.strftime("%Y-%m-%d")
    async_query(Services.Email, :send, [datetime, topstories, topkeywords])
    flush()
  end

  def view_stories do
    {:ok, topstories } = async_query(Services.Hn, :topstories)
    |> Task.await(@await_timeout)

    Enum.with_index(topstories)
    |> Enum.take(Application.get_env(:hnkeywords, :fetch_item_limit))
    |> Enum.map(&async_query(Services.Hn, :iterate, [&1]))
    |> Task.yield_many(@await_timeout)
    |> Enum.map(fn {task, {:ok, res}} -> res || Task.shutdown(task, :brutal_kill) end)
  end

  def fetch() do
    fetch_from = Application.get_env(:hnkeywords, :fetch_from)
    fetch_limit = Application.get_env(:hnkeywords, :fetch_keyword_limit)
    
    async_query(Services.Data, :fetch_keywords, [fetch_from, fetch_limit])
    |> Task.await(@await_timeout)
  end

  defp extract_keywords(result) do
    #Enum.each(result, fn {hn_id, title, url, index} -> IO.puts("#{index + 1}: #{title} (https://news.ycombinator.com/item?id=#{hn_id})") end)
    async_query(Services.Openai, :compute, [result])
    |> Task.await(@openai_timeout)
  end 

  defp save_keywords(result) do
    snapshot_name = DateTime.utc_now() |> Calendar.strftime("%Y%m%d%H%M")
    async_query(Services.Data, :save, [snapshot_name, result])
    |> Task.await(@await_timeout)
    result
  end
  
  defp async_query(client, func, opts \\ []) do
    Task.Supervisor.async_nolink(Services.TaskSupervisor,
      client, func, opts, shutdown: :brutal_kill
    )
  end

  defp flush do
    async_query(Services.Aws, :upload_db, [])
  end

end
