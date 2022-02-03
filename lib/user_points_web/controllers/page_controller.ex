defmodule UserPointsWeb.PageController do
  @moduledoc false
  use UserPointsWeb, :controller

  def index(conn, _params) do
    data = UserPoints.get_users()
    json(conn, data)
  end
end
