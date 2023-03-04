defmodule Hnkeywords.Services.Supervisor do
  alias Hnkeywords.Services
  
  use Supervisor
  
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  def init(_opts) do
    children = [
      {Task.Supervisor, name: Services.TaskSupervisor}
    ]
    # We’re using a :rest_for_one strategy here because if something goes wrong 
    # we want the child that crashed to be restarted followed by all of its children.
    Supervisor.init(children, strategy: :rest_for_one)
  end
end