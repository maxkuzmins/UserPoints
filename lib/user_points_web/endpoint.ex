defmodule UserPointsWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :user_points

  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug UserPointsWeb.Router
end
