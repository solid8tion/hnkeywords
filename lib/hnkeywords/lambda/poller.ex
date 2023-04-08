defmodule Hnkeywords.Lambda.Poller do
  alias Hnkeywords.Lambda
  use GenServer, restart: :temporary

  @await_timeout 120_000

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    case Application.get_env(:hnkeywords, :poller) do
      :lambda -> send(self(), :lambda)
      :timer -> send(self(), :timer)
      _ -> raise "Unknown poller type"
    end
    
    {:ok, []}
  end

  def handle_info(:timer, []) do
    Task.Supervisor.async_nolink(
      Hnkeywords.TaskSupervisor,
      Hnkeywords,
      Application.get_env(:hnkeywords, :timer_func),
      []
    )
    |> Task.await(@await_timeout)

    Process.send_after(self(), :timer, Application.get_env(:hnkeywords, :timer_interval_ms))
    {:noreply, []}
  end

  def handle_info(:lambda, []) do
    aws_lambda_runtime_api =
      Lambda.DefinedEnvironmentVariable.get_aws_lambda_runtime_api()

    handler = Lambda.DefinedEnvironmentVariable.get__handler()

    {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: 200}} = 
      HTTPoison.get("http://#{aws_lambda_runtime_api}/2018-06-01/runtime/invocation/next", [], [timeout: :infinity, recv_timeout: :infinity])

    lambda_runtime_aws_request_id =
      Lambda.InvocationData.get_lambda_runtime_aws_request_id(headers)

    [function_name | reversed_module_name] =
      handler
      |> String.split(".", trim: true)
      |> Enum.reverse()
      |> Enum.map(&String.to_atom/1)

    module =
      reversed_module_name
      |> Enum.reverse()
      |> Module.concat()

    
    try do

      response =
        Task.Supervisor.async_nolink(
          Hnkeywords.TaskSupervisor,
          module,
          function_name,
          [
            to_string(body),
            headers
          ]
        )
        |> Task.await(@await_timeout)

      {:ok, %HTTPoison.Response{}} = 
        HTTPoison.post("http://#{aws_lambda_runtime_api}/2018-06-01/runtime/invocation/#{lambda_runtime_aws_request_id}/response", Jason.encode!(%{status: response}))

    catch
      :exit, _err ->
        err_body = %{"errorMessage" => "Task terminated", "errorType" => "TaskExitError"}
        
        {:ok, %HTTPoison.Response{}} = 
          HTTPoison.post("http://#{aws_lambda_runtime_api}/2018-06-01/runtime/invocation/#{lambda_runtime_aws_request_id}/error", Jason.encode!(err_body))

    end

    send(self(), :lambda)
    {:noreply, []}
  end
end