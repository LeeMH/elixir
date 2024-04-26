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

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    sort_by = (params["sort_by"] || "id") |> String.to_atom()
    sort_order = (params["sort_order"] || "asc") |> String.to_atom()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order
    }

    donations = Donations.list_donations(options)
    socket =
      assign(socket,
        donations: donations,
        options: options
      )

    {:noreply, socket}
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end
end
