defmodule BookmarkWeb.BookmarksLive.Index do
  use BookmarkWeb, :live_view

  alias Bookmark.Core
  alias Bookmark.Core.{Bookmarks, Contexts}

  @impl true
  def mount(_params, _session, socket) do
    updated_socket = socket
                    |> assign(:bookmark, list_bookmark())
                    |> assign(:context, list_contexts())

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
    |> assign(:page_title, "Edit Contexts")
    |> assign(:contexts, Core.get_context!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bookmarks")
    |> assign(:bookmarks, %Bookmarks{})
    |> assign(:page_title, "New Contexts")
    |> assign(:contexts, %Contexts{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bookmark")
    |> assign(:bookmarks, nil)
    |> assign(:page_title, "Listing Contexts")
    |> assign(:contexts, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmarks = Core.get_bookmarks!(id)
    {:ok, _} = Core.delete_bookmarks(bookmarks)

    context = Core.get_context!(id)
    {:ok, _} = Core.delete_context(context)

    updated_socket = socket
                      |> assign(:bookmark, list_bookmark())
                      |> assign(:contexts, list_contexts())

    {:noreply, updated_socket}

  end

  defp list_bookmark do
    Core.list_bookmark()
  end

  defp list_contexts do
    Core.list_contexts()
  end
end
