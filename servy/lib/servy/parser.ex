defmodule Servy.Parser do

  #alias Servy.Conv, as: Conv
  # as 구문 제거시 마지막 모듈네임이 자동으로 alias가 된다.
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    # http 요청 첫라인 파싱
    [method, path, _] = String.split(request_line, " ")

    params = parse_params(params_string)

    %Conv{
      method: method,
      path: path,
      params: params
    }
  end

  def parse_params(params_string) do
    params_string |> String.trim |> URI.decode_query
  end
end
