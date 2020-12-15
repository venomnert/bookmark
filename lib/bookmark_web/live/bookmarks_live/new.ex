defmodule BookmarkWeb.BookmarksLive.New do
  use BookmarkWeb, :live_view

  alias Bookmark.Core
  alias Bookmark.Core.Bookmarks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :bookmark, list_bookmark())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bookmarks")
    |> assign(:bookmarks, Core.get_bookmarks!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bookmarks")
    |> assign(:bookmarks, %Bookmarks{})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmarks = Core.get_bookmarks!(id)
    {:ok, _} = Core.delete_bookmarks(bookmarks)

    {:noreply, assign(socket, :bookmark, list_bookmark())}
  end

  defp list_bookmark do
    Core.list_bookmark()
  end
end
