defmodule UserPointsWeb.Router do
  use UserPointsWeb, :router

  scope "/", UserPointsWeb do
    get "/", PageController, :index
  end
end
