defmodule Servy.PledgeServer do
  def create_pledge(name, amount) do
    {:ok, id} = send_pledge_to_servcie(name, amount)

    # cache the pledge:
    [ {"larry", 10}]
  end

  def recent_pledges do
    # returns the most recent pledges(cache):
    [ {"larry", 10}]
  end

  defp send_pledge_to_servcie(_name, _amount) do
    # code goes here to send pledge to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
