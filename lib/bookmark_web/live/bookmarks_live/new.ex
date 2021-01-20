defmodule BookmarkWeb.BookmarksLive.New do
  use BookmarkWeb, :live_view

  alias Bookmark.Core.{Bookmarks}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bookmarks")
    |> assign(:bookmarks, %Bookmarks{})
    |> assign(context_create: false)
  end

  defp apply_action(socket, :new_test_select, _params) do
    socket
    |> assign(:page_title, "Test context select")
    |> assign(:bookmarks, %Bookmarks{})
  end

  defp apply_action(socket, :new_test, _params) do
    socket
    |> assign(:page_title, "Test new context")
    |> assign(:bookmarks, %Bookmarks{})
  end
end
