defmodule Servy do
  def hello(name) do
    "hello. You are #{name}!"
  end
end

IO.puts Servy.hello("mhlee")
