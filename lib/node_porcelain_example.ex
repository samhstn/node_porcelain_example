defmodule NodePorcelainExample do
  require Poison
  require HTTPoison

  alias Porcelain.Process, as: Proc

  @root_url "http://localhost:4444"

  @doc"""
  See https://stackoverflow.com/questions/39772835/how-to-shutdown-an-external-process-that-was-started/39772976#39772976 for perhaps a better way of doing this.
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
