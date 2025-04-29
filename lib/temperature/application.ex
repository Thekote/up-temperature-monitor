defmodule Temperature.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Temperature.TaskSupervisor},
      Temperature.Server
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: Temperature.Supervisor
    )
  end
end
