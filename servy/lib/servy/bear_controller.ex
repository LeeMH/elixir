defmodule Servy.BearController do

  alias Servy.Wildthings


  def index(conv) do
    bears = Wildthings.list_bears()

    # TODO : Transform bears to an HTML list
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
  end

  def show(conv, %{"id" => id}) do
    %{ conv | status: 200, resp_body: "bear #{id}"}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201, resp_body: "Create a #{type} bear named #{name}!"}
  end
end
