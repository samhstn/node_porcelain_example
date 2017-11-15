defmodule NodePorcelainExample do
  @moduledoc """
  NodePorcelainExample keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Poison
  require HTTPoison

  alias Porcelain.Process, as: Proc

  @root_url "http://localhost:4444"

  @doc"""
  Can't work out better way to start and end node process
  Couldn't get https://stackoverflow.com/questions/39772835/how-to-shutdown-an-external-process-that-was-started/39772976#39772976
  working.
  """
  def request do
    System.cmd "pkill", ["node"]

    cmd = "node node_app/server/index.js"
    opts = [out: {:send, self()}]
    %Proc{pid: pid} = Porcelain.spawn_shell cmd, opts

    result = receive do
      {^pid, :data, :out, log} ->
        IO.puts "Node log => #{log}"
        HTTPoison.get! @root_url <> "/"
    end

    {"", 0} = System.cmd "pkill", ["node"]

    with %HTTPoison.Response{body: body} <- result, do: body
  end
end
