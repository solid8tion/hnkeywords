defmodule Hnkeywords do
  alias Hnkeywords.Services
  
  @openai_timeout 65_000
  @task_timeout 10_000
  #@full_timeout 60_000

  def lambda_handler(request, context) do
    """
    Request: #{Kernel.inspect(request)}
    Context: #{Kernel.inspect(context)}
    """
    |> IO.puts()
    
    args = Jason.decode!(request)
    opts = Enum.map(args, fn({key, value}) -> {String.to_existing_atom(key), value} end)

    runall(opts)
    |> IO.inspect()

    :ok
  end

  def process(opts \\ []) do
    view_stories(opts)
    |> extract_keywords() 
    |> save_keywords()
  end

  def runall(opts \\ []) do
    datetime = DateTime.utc_now() |> Calendar.strftime("%Y-%m-%d")
    days_from = opts[:days_from] || Application.get_env(:hnkeywords, :default_days_from)
    to = opts[:to] || Application.get_env(:hnkeywords, :sender_email)
    send_email = case Keyword.has_key?(opts, :send_email) and is_boolean(opts[:send_email]) do
      true -> opts[:send_email]
      false -> Application.get_env(:hnkeywords, :send_email)
    end

    topstories = process(opts)
    topkeywords = fetch_keywords(opts)

    flush()

    if send_email do
      async_query(Services.Email, :send, [datetime, topstories, topkeywords, days_from, to])
      |> Task.await(@task_timeout)
    end
    
  end

  def view_stories(opts \\ []) do
    story_limit = opts[:story_limit] || Application.get_env(:hnkeywords, :default_story_limit)

    {:ok, topstories } = async_query(Services.Hn, :topstories)
    |> Task.await(@task_timeout)

    Enum.with_index(topstories)
    |> Enum.take(story_limit)
    |> Enum.map(&async_query(Services.Hn, :iterate, [&1]))
    |> Task.yield_many(@task_timeout)
    |> Enum.map(fn {task, {:ok, res}} -> res || Task.shutdown(task, :brutal_kill) end)
  end

  def fetch_keywords(opts \\ []) do
    days_from = opts[:days_from] || Application.get_env(:hnkeywords, :default_days_from)
    keyword_limit = opts[:keyword_limit] || Application.get_env(:hnkeywords, :default_keyword_limit)
    
    async_query(Services.Data, :fetch_keywords, [days_from, keyword_limit])
    |> Task.await(@task_timeout)
  end

  defp extract_keywords(result) do
    #Enum.each(result, fn {hn_id, title, url, index} -> IO.puts("#{index + 1}: #{title} (https://news.ycombinator.com/item?id=#{hn_id})") end)
    async_query(Services.Openai, :compute, [result])
    |> Task.await(@openai_timeout)
  end 

  defp save_keywords(result) do
    snapshot_name = DateTime.utc_now() |> Calendar.strftime("%Y%m%d%H%M")
    async_query(Services.Data, :save, [snapshot_name, result])
    |> Task.await(@task_timeout)
    result
  end
  
  defp async_query(client, func, opts \\ []) do
    Task.Supervisor.async_nolink(Services.TaskSupervisor,
      client, func, opts, shutdown: :brutal_kill
    )
  end

  defp flush do
    async_query(Services.Aws, :upload_db, [])
    |> Task.await(@task_timeout)
  end

end
