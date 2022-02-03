[![.github/workflows/build_and_test.yml](https://github.com/maxkuzmins/UserPoints/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/maxkuzmins/UserPoints/actions/workflows/build_and_test.yml)
# UserPoints 🎯
It's a Phoenix app that updates User Points in a database table at a regular interval of 1 minute. The app exposes an API endpoint `/` for retrieving a max of 2 users with more than a random number of points. 

## Requirements
### PostgreSQL 14
The application requires PostgreSQL. 

If you have Docker installed, run the DB with:
```
docker pull postgres && docker run --rm -P --publish 127.0.0.1:5432:5432 --name user-points-pg -e POSTGRES_PASSWORD=mysecretpassword -d postgres
```

If installing using another method, compare DB settings against Repo configs in `/config/*.exs`.

### Elixir ~> 1.12 
Install Elixir.

## Build and test
To install dependencies, setup the database and seed with 1 million user records, check for compilation warning and errors, run format, and static code analysis tools use `mix build`.

Or `mix setup` to only install deps and setup the database.

To run tests: `mix test --trace`.

## Running
Start the app with `mix phx.server` or inside IEx with `iex -S mix phx.server`. 

Now it should start and listen on [`localhost:4000/`](http://localhost:4000).

## Examples
### First request
Timestamp of the last request is empty, no users are returned until the points update.
```
$ curl localhost:4000/
{"timestamp":null,"users":[]}
```

### Second request
Timestamp of the last request is present in subsequent calls.
```
$ curl localhost:4000/
{"timestamp":"2022-01-01 00:00:01","users":[]}
```

### After points update
The points update is triggered after 1 minute. Now the result includes up to two users with more points than `max_number`.
```
curl localhost:4000/
{"timestamp":"2022-01-01 00:01:01","users":[{"id":401,"points":73},{"id":402,"points":72}]}
```

The interval could be configured at runtime from IEx.
```
iex(1)> new_interval = 5000
5000
iex(2)> Application.put_env(:user_points, :points_update_interval_ms, new_interval)
:ok
```
