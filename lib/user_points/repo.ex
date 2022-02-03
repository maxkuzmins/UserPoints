defmodule UserPoints.Repo do
  use Ecto.Repo,
    otp_app: :user_points,
    adapter: Ecto.Adapters.Postgres
end
