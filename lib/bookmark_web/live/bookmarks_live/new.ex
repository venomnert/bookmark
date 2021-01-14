defmodule BookmarkWeb.BookmarksLive.New do
  use BookmarkWeb, :live_view

  alias Bookmark.Core
  alias Bookmark.Core.{Bookmarks, Contexts}

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

end
