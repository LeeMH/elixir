defmodule Servy.PledgeServer do
  @name :pledge_server

  ## Server Side run
  def start do
    IO.puts "Starting the pledge server..."
    pid = spawn(__MODULE__, :listen_loop, [[]])
    ## PID를 :pledge_server로 등록한다.
    Process.register(pid, @name)
    pid
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

        {sender, :total_pledged} ->
          total =
            ## elem은 튜플의 n번째 요소를 가져오는 함수이다. 여기서는 amount를 가져온다.
            Enum.map(state, &elem(&1, 1))
            |> Enum.sum
          send sender, {:response, total}
          listen_loop(state)

      ## 메세지 박스에 매칭되지 않는 메세지가 계속 쌓이는것을 방지하기 위해 default 절을 추가한다
      unexpected ->
        IO.puts "Unexpected messaged: #{inspect unexpected}"
        listen_loop(state)
    end

  end

  ## Client Side run
  def create_pledge(name, amount) do
    send @name, {self(), :create_pledge, name, amount}

    receive do {:response, status} -> status end
  end

  def recent_pledges() do
    send @name, {self(), :recent_pledges}

    receive do {:response, pledges} -> pledges end
  end

  def total_pledges() do
    send @name, {self(), :total_pledged}

    receive do {:response, total} -> total end
  end

  defp send_pledge_to_servcie(_name, _amount) do
    # code goes here to send pledge to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end


alias Servy.PledgeServer

PledgeServer.start()

IO.inspect PledgeServer.create_pledge("larry", 10)
IO.inspect PledgeServer.create_pledge("moe", 20)
IO.inspect PledgeServer.create_pledge("curly", 30)
IO.inspect PledgeServer.create_pledge("daisy", 40)
IO.inspect PledgeServer.create_pledge("grace", 50)

IO.inspect PledgeServer.recent_pledges()

IO.inspect PledgeServer.total_pledges()
