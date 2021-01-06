defmodule BookmarkWeb.BookmarksLive.Index do
  use BookmarkWeb, :live_view

  alias Bookmark.Core
  alias Bookmark.Core.{Bookmarks, Contexts}

  @impl true
  def mount(_params, _session, socket) do
    updated_socket = assign(socket, :bookmark, list_bookmark())

    {:ok, updated_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bookmarks")
    |> assign(:bookmarks, Core.get_bookmarks!(id))
    |> assign(:contexts, Core.get_context!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bookmarks")
    |> assign(:bookmarks, %Bookmarks{})
    |> assign(:contexts, %Contexts{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bookmarks")
    |> assign(:bookmarks, nil)
    |> assign(:contexts, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmarks = Core.get_bookmarks!(id)
    {:ok, _} = Core.delete_bookmarks(bookmarks)

    updated_socket = assign(socket, :bookmark, list_bookmark())

    {:noreply, updated_socket}
  end

  defp list_bookmark, do: Core.list_bookmark()

end
