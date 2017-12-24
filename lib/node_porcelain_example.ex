defmodule NodePorcelainExample do
  require Poison
  require HTTPoison

  alias Porcelain.Process, as: Proc

  @root_url "http://localhost:4444"

  defp kill_node do
    {ps_procs, 0} = System.cmd "ps", ["-ef"]

    node_proc_pid = ps_procs
    |> String.split("\n")
    |> Enum.find(&(Regex.match? ~r/\d node \S*node_app\/server\/index.js/, &1))
    |> case do
      nil -> nil
      n_pid -> n_pid |> String.split |> Enum.at(1)
    end

    if node_proc_pid do
      System.cmd "kill", ["-9", node_proc_pid]
    end
  end

  @doc"""
  See https://stackoverflow.com/questions/39772835/how-to-shutdown-an-external-process-that-was-started/39772976#39772976 for perhaps a better way of doing this.
  """
  def request do
    kill_node()

    cmd = "node node_app/server/index.js"
    opts = [out: {:send, self()}]
    %Proc{pid: pid} = Porcelain.spawn_shell cmd, opts

    result = receive do
      {^pid, :data, :out, log} ->
        IO.puts "Node log => #{log}"
        HTTPoison.get! @root_url <> "/"
    end

    kill_node()

    with %HTTPoison.Response{body: body} <- result, do: body
  end
end
