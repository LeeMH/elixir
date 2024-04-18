defmodule Servy.PledgeServer do
  alias Servy.PledgeServer

  def start do
    IO.puts "Starting the pledge server..."
    pid = spawn(PledgeServer, :listen_loop, [[]])
  end

  def listen_loop(state) do
    IO.puts "\nWaiting for a message..."

    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_servcie(name, amount)
        ## 기존 state 앞에 새로 생성된 pledge를 추가한다.
        most_recent_pledges = Enum.take(state, 2)
        new_state = [ {name, amount} | most_recent_pledges ]

        ## 요청자에게 응답 전송
        send sender, {:response, id}

        ## 해당 상태를 유지하기 위해, 다시 listen_loop에 해당값을 전달한다.
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send sender, {:response, state}
        listen_loop(state)
    end

  end

  def create_pledge(pid, name, amount) do
    send pid, {self(), :create_pledge, name, amount}

    receive do {:response, status} -> status end
  end

  def recent_pledges(pid) do
    send pid, {self(), :recent_pledges}

    receive do {:response, pledges} -> pledges end
  end

  defp send_pledge_to_servcie(_name, _amount) do
    # code goes here to send pledge to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end


alias Servy.PledgeServer

pid = PledgeServer.start()

IO.inspect PledgeServer.create_pledge(pid, "larry", 10)
IO.inspect PledgeServer.create_pledge(pid, "moe", 20)
IO.inspect PledgeServer.create_pledge(pid, "curly", 30)
IO.inspect PledgeServer.create_pledge(pid, "daisy", 40)
IO.inspect PledgeServer.create_pledge(pid, "grace", 50)

IO.inspect PledgeServer.recent_pledges(pid)
