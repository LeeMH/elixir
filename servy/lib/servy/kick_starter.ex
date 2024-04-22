defmodule Servy.KickStarter do
  use GenServer

  def start do
    IO.puts "Starting the kickstarter"
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts "Starting the HTTP server..."
    server_pid = spawn(Servy.HttpServer, :start, [4000])
    Process.link(server_pid)
    Process.register(server_pid, :http_server)
    {:ok, server_pid}
  end
end
