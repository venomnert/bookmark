defmodule BookmarkWeb.ContextLive.Index do
  use BookmarkWeb, :live_view

  alias Bookmark.Core
  alias Bookmark.Core.Context

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :contexts, list_contexts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Context")
    |> assign(:context, Core.get_context!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Context")
    |> assign(:context, %Context{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Contexts")
    |> assign(:context, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    context = Core.get_context!(id)
    {:ok, _} = Core.delete_context(context)

    {:noreply, assign(socket, :contexts, list_contexts())}
  end

  defp list_contexts do
    Core.list_contexts()
  end
end
