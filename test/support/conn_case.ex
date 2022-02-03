defmodule UserPointsWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use UserPointsWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias UserPoints.Repo

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import UserPointsWeb.ConnCase

      alias UserPointsWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint UserPointsWeb.Endpoint
    end
  end

  setup tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def seed(user_count) do
    ts = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    1..user_count
    |> Stream.map(fn _ -> %{updated_at: ts, inserted_at: ts} end)
    |> Enum.to_list()
    |> Enum.each(fn users ->
      {1, nil} = Repo.insert_all(UserPoints.Data.User, [users])
    end)
  end

  def truncate do
    Ecto.Adapters.SQL.query(Repo, "TRUNCATE users")
  end
end
