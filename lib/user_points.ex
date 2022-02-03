defmodule UserPoints do
  @moduledoc """
  GenServer for managing user points.
  """

  use GenServer

  import Ecto.Query

  alias UserPoints.Data.User
  alias UserPoints.Repo

  defstruct max_number: 0, last_query_ts: nil

  @default_points_update_interval_ms 60 * 1000
  @get_users_response_size 2

  @doc """
  Queries the database for all users with more points than max_number, retrieves a max of 2 users.
  Updates the genserver state timestamp with the current timestamp.
  Returns the users just retrieved from the database, as well as the timestamp of the previous handle_call.
  """
  def get_users, do: GenServer.call(UserPoints, :get_users)

  def start_link(opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %UserPoints{})
    if opts[:name], do: Process.register(pid, opts[:name])
    {:ok, pid}
  end

  @impl true
  def init(state) do
    schedule_update_points()

    {:ok, state}
  end

  @impl true
  def handle_call(:get_users, _from, state) do
    ts_now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    reply = handle_get_users(state.max_number, state.last_query_ts)
    {:reply, reply, %UserPoints{state | last_query_ts: ts_now}}
  end

  @impl true
  def handle_info(:update_points, state) do
    schedule_update_points()
    new_state = handle_update_points(state)

    {:noreply, new_state}
  end

  defp schedule_update_points do
    interval =
      Application.get_env(
        :user_points,
        :points_update_interval_ms,
        @default_points_update_interval_ms
      )

    Process.send_after(self(), :update_points, interval)
  end

  defp handle_update_points(state) do
    ts = NaiveDateTime.utc_now()

    update(User, set: [points: fragment("floor(random()*101)"), updated_at: ^ts])
    |> Repo.update_all([])

    %UserPoints{state | max_number: :rand.uniform(101) - 1}
  end

  defp handle_get_users(max_number, last_query_ts) do
    query =
      from u in User,
        where: u.points > ^max_number,
        select: map(u, [:id, :points]),
        limit: @get_users_response_size

    users = Repo.all(query)
    timestamp = if last_query_ts, do: NaiveDateTime.to_string(last_query_ts), else: last_query_ts

    %{
      users: users,
      timestamp: timestamp
    }
  end
end
