defmodule BookmarkWeb.BookmarksLive.Show do
  use BookmarkWeb, :live_view

  alias Bookmark.Core

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    bookmarks = Core.get_bookmarks_with_context!(id)
    contexts = Map.get(bookmarks, :contexts)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:bookmarks, bookmarks)
     |> assign(:contexts, contexts)
    }
  end

  defp page_title(:show), do: "Show Bookmark"
  defp page_title(:edit), do: "Edit Bookmark"
end
