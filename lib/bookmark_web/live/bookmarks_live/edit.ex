defmodule BookmarkWeb.BookmarksLive.Edit do
  use BookmarkWeb, :live_view

  alias Bookmark.Core

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bookmarks")
    |> assign(:bookmarks, Core.get_bookmarks_with_context!(id))
  end
end
