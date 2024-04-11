defmodule Servy.Handler do

  @moduledoc """
  Handles HTTP requests
  """

  alias Servy.Conv
  alias Servy.BearController

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



  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    %{ conv | status: 201, resp_body: "Create a #{conv.params["type"]} bear named #{conv.params["name"]}!"}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{} = conv) do
    %{ conv | status: 404, resp_body: "no #{conv.path} here"}
  end

  def handle_file({:ok, contents}, conv), do: %{ conv | status: 200, resp_body: contents }

  def handle_file({:error, :enoent}, conv), do: %{ conv | status: 404, resp_body: "File not found!"}

  def handle_file({:error, reason}, conv), do: %{ conv | status: 500, resp_body: "File error #{reason}"}

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

end

# 첫번째 요청
request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response


# 두번째 요청
request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

# 세번째 요청
request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

# 네번째 요청
request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

# 다섯번째 요청
request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response


# 여섯번째 요청
request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

# 일곱번째 요청
request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response


# 여덟번째 요청
request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Yellow
"""

response = Servy.Handler.handle(request)

IO.puts response

# 아홉번째 요청
request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: multipart/form-data
Content-Length: 21

name=Baloo&type=Yellow
"""

response = Servy.Handler.handle(request)

IO.puts response
