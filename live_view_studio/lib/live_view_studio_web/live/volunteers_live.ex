defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.volunteer_form form={@form} />
      <pre>
        <%#= inspect(@form, pretty: true) %>
      </pre>
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

  def volunteer_form(assigns) do
    ~H"""
    <.form for={@form} phx-submit="save" phx-change="validate">
      <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000"/>
      <.input field={@form[:phone]} type="tel" placeholder="Phone" autocomplete="off" phx-debounce="blur"/>
      <.button phx-disable-with="Saving...">
        Check In
      </.button>
    </.form>
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

    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        socket =
          stream_insert(socket,
            :volunteers,
            volunteer,
            at: 0
          )
        changeset = Volunteers.change_volunteer(%Volunteer{})
        {:noreply, assign(socket, :form, to_form(changeset))}
      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
