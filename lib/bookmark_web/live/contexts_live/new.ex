defmodule BookmarkWeb.ContextsLive.New do
  use BookmarkWeb, :live_view

  alias Bookmark.Core
  alias Bookmark.Core.{Contexts}

  @impl true
  def mount(_params, _session, socket) do
    updated_socket = assign(socket, :context, list_contexts())

    {:ok, updated_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket =
      socket
      |> allow_upload(:media,
        accept: ~w(.png .jpeg .jpg .wav .mp4 .mpg .wmv .avi),
        max_entries: 5,
        max_file_size: 100_000_000
      )

    socket
    |> assign(:page_title, "New Contexts")
    |> assign(:contexts, %Contexts{})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    context = Core.get_context!(id)
    {:ok, _} = Core.delete_context(context)

    updated_socket = assign(socket, :contexts, list_contexts())

    {:noreply, updated_socket}
  end

  defp list_contexts do
    Core.list_contexts()
  end
end
