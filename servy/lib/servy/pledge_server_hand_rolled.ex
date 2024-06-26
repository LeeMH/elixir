defmodule Servy.GenericServer do
  ## 일반화된 서버를 위해, 초기 상태, name을 argument로 받아서 start 한다.
  def start(callback_module, initial_state, name) do
    IO.puts "Starting the pledge server..."
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    ## PID를 :pledge_server로 등록한다.
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send pid, {:call, self(), message}
    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state, callback_module)
      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)
      ## 메세지 박스에 매칭되지 않는 메세지가 계속 쌓이는것을 방지하기 위해 default 절을
      unexpected ->
        IO.puts "Unexpected messaged: #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.PledgeServerHandRolled do
  @name :pledge_server_hand_rolled

  alias Servy.GenericServer

  def start() do
    IO.puts "Starting the pledge server..."
    GenericServer.start(__MODULE__, [], @name)
  end

  # server callbacks
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
    GenericServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    GenericServer.call @name, :recent_pledges
  end

  def total_pledges() do
    GenericServer.call @name, :total_pledged
  end

  def clear do
    GenericServer.cast @name, :clear
  end

end


# alias Servy.PledgeServerHandRolled

# pid = PledgeServerHandRolled.start()

# send pid, {:stop, "hammertime"}

# IO.inspect PledgeServerHandRolled.create_pledge("larry", 10)
# IO.inspect PledgeServerHandRolled.create_pledge("moe", 20)
# IO.inspect PledgeServerHandRolled.create_pledge("curly", 30)
# IO.inspect PledgeServerHandRolled.create_pledge("daisy", 40)

# PledgeServerHandRolled.clear()

# IO.inspect PledgeServerHandRolled.create_pledge("grace", 50)

# IO.inspect PledgeServerHandRolled.recent_pledges()

# IO.inspect PledgeServerHandRolled.total_pledges()
