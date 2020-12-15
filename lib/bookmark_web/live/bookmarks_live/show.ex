defmodule BookmarkWeb.BookmarksLive.Show do
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
     |> assign(:bookmarks, Core.get_bookmarks!(id))}
  end

  defp page_title(:show), do: "Show Bookmarks"
  defp page_title(:edit), do: "Edit Bookmarks"
end
