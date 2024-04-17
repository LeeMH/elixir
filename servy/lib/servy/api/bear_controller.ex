defmodule Servy.Api.BearController do

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!(keys: :atoms_desc)

    %{ conv | status: 200, resp_content_type: "application/json", resp_body: json }
  end
end
