import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :user_points, UserPoints.Repo,
  username: "postgres",
  password: "mysecretpassword",
  hostname: "localhost",
  database: "user_points_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :user_points, UserPointsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "aQxRmkI5kIs2R7v+bowfMCribClVt6ERqfDRv4sWTRn6ZcbydZJlf5Jl5a7a8y4e",
  server: false

# In test we don't send emails.
config :user_points, UserPoints.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
