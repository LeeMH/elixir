defmodule Servy.BearController do

  def index(conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
  end

  def show(conv, %{"id" => id}) do
    %{ conv | status: 200, resp_body: "bear #{id}"}
  end
end
