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
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state)
      {:cast, message} ->
        new_state = handle_cast(message, state)
        listen_loop(new_state)
      ## 메세지 박스에 매칭되지 않는 메세지가 계속 쌓이는것을 방지하기 위해 default 절을
      unexpected ->
        IO.puts "Unexpected messaged: #{inspect unexpected}"
        listen_loop(state)
    end
  end

  def handle_cast(:clear, _state) do
    []
  end

  def handle_call(:total_pledged, state) do
    total =
      ## elem은 튜플의 n번째 요소를 가져오는 함수이다. 여기서는 amount를 가져온다.
      Enum.map(state, &elem(&1, 1))
      |> Enum.sum
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_servcie(name, amount)
    ## 기존 state 앞에 새로 생성된 pledge를 추가한다.
    most_recent_pledges = Enum.take(state, 2)
    new_state = [ {name, amount} | most_recent_pledges ]
    {id, new_state}
  end

  defp send_pledge_to_servcie(_name, _amount) do
    # code goes here to send pledge to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  ## Client Side run
  def create_pledge(name, amount) do
    call @name, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    call @name, :recent_pledges
  end

  def total_pledges() do
    call @name, :total_pledged
  end

  def clear do
    cast @name, :clear
  end

  ## Helper Functions
  def call(pid, message) do
    send pid, {:call, self(), message}
    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end
end


alias Servy.PledgeServer

pid = PledgeServer.start()

send pid, {:stop, "hammertime"}

IO.inspect PledgeServer.create_pledge("larry", 10)
IO.inspect PledgeServer.create_pledge("moe", 20)
IO.inspect PledgeServer.create_pledge("curly", 30)
IO.inspect PledgeServer.create_pledge("daisy", 40)

PledgeServer.clear()

IO.inspect PledgeServer.create_pledge("grace", 50)

IO.inspect PledgeServer.recent_pledges()

IO.inspect PledgeServer.total_pledges()
