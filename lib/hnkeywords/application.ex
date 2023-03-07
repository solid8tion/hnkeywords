defmodule Hnkeywords.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    download_db()

    children = [
      # Starts a worker by calling: Hnkeywords.Worker.start_link(arg)
      # {Hnkeywords.Worker, arg}
      Hnkeywords.Repo,
      Hnkeywords.Services.Supervisor,
      {Task.Supervisor, name: Hnkeywords.TaskSupervisor},
      Hnkeywords.Lambda.Poller
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hnkeywords.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp download_db do
    bucket_name = Application.get_env(:hnkeywords, :s3_bucket)
    db_filename = Application.get_env(:hnkeywords, :db_filename)
    db_filepath = Application.get_env(:hnkeywords, :db_filepath)
    %{:status_code => 200, :body => body} = ExAws.S3.get_object(bucket_name, db_filename) |> ExAws.request!()
    {:ok, file} = File.open(db_filepath, [:write])
    IO.binwrite(file, body)
    File.close(file)
  end

end
