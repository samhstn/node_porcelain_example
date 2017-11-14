defmodule NodePorcelainExampleWeb.Router do
  use NodePorcelainExampleWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", NodePorcelainExampleWeb do
    pipe_through :api
  end
end
