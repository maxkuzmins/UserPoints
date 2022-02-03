defmodule UserPointsWeb.PageControllerTest do
  use UserPointsWeb.ConnCase, async: false

  import Ecto.Query

  alias UserPointsWeb.ConnCase
  alias UserPoints.Repo
  alias UserPoints.Data.User

  @default_points_update_interval_ms 60 * 1000

  setup do
    :ok = set_schedule_interval(@default_points_update_interval_ms)
    :ok = reset_genserver()

    ConnCase.truncate()
    ConnCase.seed(10)
    :ok
  end

  describe "Before points update" do
    test "First GET /", %{conn: conn} do
      conn = get(conn, "/")
      expected = %{"timestamp" => nil, "users" => []}
      assert expected == json_response(conn, 200)
    end

    test "Second GET /", %{conn: conn} do
      conn = get(conn, "/")
      _first_response = json_response(conn, 200)

      conn = get(conn, "/")
      response = json_response(conn, 200)
      assert response["users"] === []
      assert valid_timestamp?(response["timestamp"])
    end
  end

  describe "After points update" do
    test "First GET /", %{conn: conn} do
      ts_before_points_update = NaiveDateTime.utc_now()
      :ok = set_schedule_interval(1000)
      :ok = reset_genserver()

      :ok = wait_for_points_update(ts_before_points_update)

      # Delay the second points update
      :ok = set_schedule_interval(@default_points_update_interval_ms)

      conn = get(conn, "/")
      response = json_response(conn, 200)

      max_number = get_max_number()
      assert nil === response["timestamp"]
      assert valid_users?(response["users"], max_number)
    end

    test "Second GET /", %{conn: conn} do
      ts_before_points_update = NaiveDateTime.utc_now()
      :ok = set_schedule_interval(1000)
      :ok = reset_genserver()

      :ok = wait_for_points_update(ts_before_points_update)

      # Delay the second points update
      :ok = set_schedule_interval(@default_points_update_interval_ms)

      conn = get(conn, "/")
      _first_response = json_response(conn, 200)
      conn = get(conn, "/")
      response = json_response(conn, 200)

      max_number = get_max_number()
      assert valid_timestamp?(response["timestamp"])
      assert valid_users?(response["users"], max_number)
    end
  end

  defp get_max_number do
    Process.whereis(UserPoints)
    |> :sys.get_state()
    |> Map.fetch!(:max_number)
  end

  defp valid_timestamp?(naive_ts) when is_binary(naive_ts) do
    naive_ts
    |> String.replace(" ", "T")
    |> NaiveDateTime.from_iso8601()
    |> elem(0) === :ok
  end

  defp valid_timestamp?(_), do: false

  defp valid_users?(users, max_number) do
    is_list(users) and length(users) <= 2 and
      Enum.drop_while(users, &valid_user?(&1, max_number)) === []
  end

  defp valid_user?(%{"id" => id, "points" => points}, max_number) do
    valid_id?(id) and valid_points?(points) and points > max_number
  end

  defp valid_id?(id), do: is_integer(id)

  defp valid_points?(points) do
    is_integer(points) and points in 0..100
  end

  defp reset_genserver do
    :ok = GenServer.stop(UserPoints)
    wait_for_genserver_is_up()
  end

  defp set_schedule_interval(new_interval) do
    Application.put_env(:user_points, :points_update_interval_ms, new_interval)
  end

  defp wait_for_genserver_is_up do
    wait_for(fn -> is_pid(Process.whereis(UserPoints)) end)
  end

  defp wait_for_points_update(wait_start_ts) do
    wait_for(
      fn ->
        query =
          from u in User,
            where: u.updated_at > ^wait_start_ts,
            limit: 1

        Repo.all(query) != []
      end,
      20,
      500
    )
  end

  defp wait_for(fun, attempts_left \\ 20, check_interval_ms \\ 100)

  defp wait_for(_, 0, _), do: :error

  defp wait_for(fun, attempts_left, check_interval_ms) do
    if fun.() in [:ok, true] do
      :ok
    else
      :timer.sleep(check_interval_ms)
      wait_for(fun, attempts_left - 1, check_interval_ms)
    end
  end
end
