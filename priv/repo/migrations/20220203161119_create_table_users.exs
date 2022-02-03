defmodule UserPoints.Repo.Migrations.CreateTableUsers do
  use Ecto.Migration

  def up do
    create table("users", primary_keys: true, comment: "Users and their points") do
      add :points, :integer, null: false, default: 0

      timestamps()
    end

    create constraint("users", :points_range_0_100, check: "points BETWEEN 0 AND 100")
  end

  def down do
    drop table("users")
  end
end
