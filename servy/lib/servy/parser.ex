defmodule Servy.Parser do

  #alias Servy.Conv, as: Conv
  # as 구문 제거시 마지막 모듈네임이 자동으로 alias가 된다.
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = request
      |> String.split("\n\n")

    [method, path, _] =
      top
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %Conv{
      method: method,
      path: path
    }
  end
end
