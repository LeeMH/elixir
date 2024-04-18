defmodule Servy.Handler do

  @moduledoc """
  Handles HTTP requests
  """

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam
  alias Servy.Fetcher

  @pages_path Path.expand("pages", File.cwd!)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  @doc """
  Transforms the request into a respond
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    #|> emojify
    |> format_response
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
    Fetcher.async(fn -> Servy.VideoCam.get_snapshot("cam-1") end)
    Fetcher.async(fn -> Servy.VideoCam.get_snapshot("cam-2") end)
    Fetcher.async(fn -> Servy.VideoCam.get_snapshot("cam-3") end)
    Fetcher.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshot1 = Fetcher.get_result()
    snapshot2 = Fetcher.get_result()
    snapshot3 = Fetcher.get_result()
    where_is_bigfoot = Fetcher.get_result()
    snapshots = [snapshot1, snapshot2, snapshot3]

    %{ conv | status: 200, resp_body: inspect {snapshots, where_is_bigfoot}}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | status: 200, resp_body: "Awake!"}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{} = conv) do
    %{ conv | status: 404, resp_body: "No #{conv.path} here!"}
  end

  def handle_file({:ok, contents}, conv), do: %{ conv | status: 200, resp_body: contents }

  def handle_file({:error, :enoent}, conv), do: %{ conv | status: 404, resp_body: "File not found!"}

  def handle_file({:error, reason}, conv), do: %{ conv | status: 500, resp_body: "File error #{reason}"}

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end

end
