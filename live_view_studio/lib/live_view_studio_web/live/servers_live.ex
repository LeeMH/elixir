defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers

  def mount(_params, _session, socket) do
    IO.inspect(self(), lable: "MOUNT")
    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers,
        coffees: 0
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    IO.inspect(self(), lable: "HANDLE_PARAMS ID=#{id}")
    server = Servers.get_server!(id)
    {:noreply,
      assign(socket,
        selected_server: server,
        page_title: "What's up #{server.name}")}
  end

  ## default clause
  def handle_params(_, _uri, socket) do
    IO.inspect(self(), lable: "DEFAULT HANDLE_PARAMS")
    {:noreply,
    assign(socket, selected_server: hd(socket.assigns.servers))}
  end

  def render(assigns) do
    IO.inspect(self(), lable: "RENDER")
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <!-- href={~p"/servers?id=#{server.id}"} 같은 표현임 -->
          <.link
            :for={server <- @servers}
            patch={~p"/servers?#{[id: server]}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <div class="server">
            <div class="header">
              <h2><%= @selected_server.name %></h2>
              <span class={@selected_server.status}>
                <%= @selected_server.status %>
              </span>
            </div>
            <div class="body">
              <div class="row">
                <span>
                  <%= @selected_server.deploy_count %> deploys
                </span>
                <span>
                  <%= @selected_server.size %> MB
                </span>
                <span>
                  <%= @selected_server.framework %>
                </span>
              </div>
              <h3>Last Commit Message:</h3>
              <blockquote>
                <%= @selected_server.last_commit_message %>
              </blockquote>
            </div>
          </div>
          <div class="links">
          <.link navigate={~p"/topsecret"}>
              Top Secret
            </.link>
            <.link navigate={~p"/light"}>
              Adjust Lights
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("drink", _, socket) do
    IO.inspect(self(), lable: "HANDLE_EVENT")
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end
end
