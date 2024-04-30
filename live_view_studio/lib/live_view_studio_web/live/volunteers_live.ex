defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer
  alias LiveViewStudioWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end

    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component module={VolunteerFormComponent} id={:new} count={@count} />
      <div id="volunteers" phx-update="stream">
        <.volunteer
          :for={{volunteer_id, volunteer} <- @streams.volunteers}
          volunteer={volunteer}
          id={volunteer_id}
        />
      </div>
    </div>
    """
  end


  def volunteer(assigns) do
    ~H"""
    <div
      class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
      id={@id}
    >
      <div class="name">
        <%= @volunteer.name %>
      </div>
      <div class="phone">
        <%= @volunteer.phone %>
      </div>
      <div class="status" phx-click="toggle-status" phx-value-id={@volunteer.id}>
        <button>
          <%= if @volunteer.checked_out, do: "Check In", else: "Check Out" %>
        </button>
      </div>
    </div>
    """
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, volunteer} = Volunteers.update_volunteer(
      volunteer,
      %{checked_out: !volunteer.checked_out}
    )

    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket = socket
      |> update(:count, &(&1 + 1))
      |> stream_insert(:volunteers, volunteer, at: 0)
    {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end


end
