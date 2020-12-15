defmodule BookmarkWeb.ContextLive.Show do
  use BookmarkWeb, :live_view

  alias Bookmark.Core

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:context, Core.get_context!(id))}
  end

  defp page_title(:show), do: "Show Context"
  defp page_title(:edit), do: "Edit Context"
end
