defmodule BookmarkWeb.ContextsLive.Edit do
  use BookmarkWeb, :live_view

  alias Bookmark.Core

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
    |> assign(:page_title, "Edit Contexts")
    |> assign(:contexts, Core.get_context!(id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contexts = Core.get_context!(id)
    {:ok, _} = Core.delete_context(contexts)

    {:noreply, assign(socket, :contexts, list_contexts())}
  end

  defp list_contexts do
    Core.list_contexts()
  end
end
