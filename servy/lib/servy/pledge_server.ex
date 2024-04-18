defmodule Servy.PledgeServer do

  def listen_loop(state) do
    IO.puts "\nWaiting for a message..."

    receive do
      {:create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_servcie(name, amount)
        ## 기존 state 앞에 새로 생성된 pledge를 추가한다.
        new_state = [ {name, amount} | state ]
        IO.puts "#{name} pledged #{amount}!"
        IO.puts "New state is #{inspect new_state}"
        ## 해당 상태를 유지하기 위해, 다시 listen_loop에 해당값을 전달한다.
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send sender, {:response, state}
        IO.puts "Sent pledges to #{inspect sender}"
        listen_loop(state)
    end

  end

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
