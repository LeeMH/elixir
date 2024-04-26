defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    ## mount 이후 즉시 handle_param이 호출되기 때문에 2번 query 실행 방지를 위해 로직 제거
    # donations = Donations.list_donations()

    # socket =
    #   assign(socket,
    #     donations: donations
    #   )

    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = (params["sort_by"] || "id") |> String.to_atom()
    sort_order = (params["sort_order"] || "asc") |> String.to_atom()

    page = (params["page"] || "1") |> String.to_integer()
    per_page = (params["per_page"] || "5") |> String.to_integer()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    donations = Donations.list_donations(options)
    socket =
      assign(socket,
        donations: donations,
        options: options
      )

    {:noreply, socket}
  end

  def sort_link(assigns) do
    params = %{
      assigns.options
      | sort_by: assigns.sort_by, sort_order: next_sort_order(assigns.options.sort_order)
    }

    assigns = assign(
      assigns,
        params: params
      )

    ~H"""
    <.link patch={
      ~p"/donations?#{@params}"
    }>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    IO.puts "select-per-page 함수 들어옴!!!"
    params = %{socket.assigns.options | per_page: per_page}

    socket = push_patch(socket, to: ~p"/donations?#{params}")

    {:noreply, socket}
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end
end
