
defmodule Servy.PledgeServer do
  @name :pledge_server

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  def start() do
    IO.puts "Starting the pledge server..."
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  ############################
  # server callbacks
  ############################

  ## GenServer start될때 호출된다.
  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    new_state = %{ state | cache_size: size}
    {:noreply, new_state}
  end


  def handle_call(:total_pledged, _from, state) do
    total =
      ## elem은 튜플의 n번째 요소를 가져오는 함수이다. 여기서는 amount를 가져온다.
      Enum.map(state.pledges, &elem(&1, 1))
      |> Enum.sum
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_servcie(name, amount)
    ## 기존 state 앞에 새로 생성된 pledge를 추가한다.
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cache_pledges = [ {name, amount} | most_recent_pledges ]
    new_state = %{ state | pledges: cache_pledges }
    {:reply, id, new_state}
  end

  defp send_pledge_to_servcie(_name, _amount) do
    # code goes here to send pledge to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  ############################
  ## Client Side run
  ############################
  def create_pledge(name, amount) do
    GenServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    GenServer.call @name, :recent_pledges
  end

  def total_pledges() do
    GenServer.call @name, :total_pledged
  end

  def clear do
    GenServer.cast @name, :clear
  end

  def set_cache_size(size) do
    GenServer.cast @name, {:set_cache_size, size}
  end

  defp fetch_recent_pledges_from_service do
    # 실제 외부서비스를 이용해서 초기화 한다.
    # 테스트를 위해 임시로 하드코딩된 결과를 리턴
    [ {"wilma", 15}, {"fred", 25} ]
  end

end


alias Servy.PledgeServer

{:ok, pid} = PledgeServer.start()

#send pid, {:stop, "hammertime"}

PledgeServer.set_cache_size(4)

IO.inspect PledgeServer.create_pledge("larry", 10)
# PledgeServer.clear()
# IO.inspect PledgeServer.create_pledge("moe", 20)
# IO.inspect PledgeServer.create_pledge("curly", 30)
# IO.inspect PledgeServer.create_pledge("daisy", 40)



IO.inspect PledgeServer.create_pledge("grace", 50)

IO.inspect PledgeServer.recent_pledges()

IO.inspect PledgeServer.total_pledges()
