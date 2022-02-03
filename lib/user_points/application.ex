defmodule UserPoints.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UserPoints.Repo,
      UserPointsWeb.Endpoint,
      {UserPoints, name: UserPoints}
    ]

    opts = [strategy: :one_for_one, name: UserPoints.Supervisor, max_restarts: 1000]
    Supervisor.start_link(children, opts)
  end
end
