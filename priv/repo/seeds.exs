alias UserPoints.Repo

desired_user_count = 1_000_000
params_per_entry = 2
pg_param_limit = 65535

ts = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
chunk_size = trunc(pg_param_limit / params_per_entry)

1..desired_user_count
|> Stream.map(fn _ -> %{updated_at: ts, inserted_at: ts} end)
|> Stream.chunk_every(chunk_size)
|> Stream.each(fn chunk ->
  {_, nil} = Repo.insert_all(UserPoints.Data.User, chunk)
end)
|> Stream.run()

# faster insert
# vals =
#   NaiveDateTime.utc_now()
#   |> NaiveDateTime.truncate(:second)
#   |> NaiveDateTime.to_string()
#   |> List.duplicate(desired_user_count)
#   |> Enum.intersperse(",")
#   |> List.to_string()

# query = """
# INSERT INTO users(inserted_at, updated_at)
# SELECT inserted_at, updated_at
# FROM unnest('{#{vals}}'::date[], '{#{vals}}'::date[]) AS t (inserted_at, updated_at)
# """

# {:ok, %Postgrex.Result{num_rows: desired_user_count}} = Ecto.Adapters.SQL.query(Repo, query)
