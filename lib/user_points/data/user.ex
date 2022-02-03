defmodule UserPoints.Data.User do
  @moduledoc """
  User schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  schema "users" do
    field :points, :integer, default: 0

    timestamps()
  end
end
