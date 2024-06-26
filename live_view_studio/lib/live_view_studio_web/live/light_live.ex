defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :brightness, 10)}
  end

  # render
  def render(assigns) do
    IO.puts(inspect(assigns))

    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{assigns.brightness}%"}>
          <!--
          <%= @brightness %>%
          -->
          <%= assigns.brightness %>%
        </span>
      </div>

      <button phx-click="off">
        <img src="/images/light-off.svg" />
      </button>
      <button phx-click="down">
        <img src="/images/down.svg" />
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" />
      </button>
      <button phx-click="on">
        <img src="/images/light-on.svg" />
      </button>
    </div>
    """
  end

  def handle_event("on", _payload, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("up", _payload, socket) do
    socket = update(socket, :brightness, &(&1 + 10))
    {:noreply, socket}
  end

  def handle_event("off", _payload, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("down", _payload, socket) do
    socket = update(socket, :brightness, &(&1 - 10))
    {:noreply, socket}
  end
end
