defmodule BookmarkWeb.BookmarksLive.FormComponent do
  use BookmarkWeb, :live_component

  alias Bookmark.Core

  @impl true
  def update(%{bookmarks: bookmarks} = assigns, socket) do
    changeset = Core.change_bookmarks(bookmarks)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"bookmarks" => bookmarks_params}, socket) do
    changeset =
      socket.assigns.bookmarks
      |> Core.change_bookmarks(bookmarks_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"bookmarks" => bookmarks_params}, socket) do
    save_bookmarks(socket, socket.assigns.action, bookmarks_params)
  end

  defp save_bookmarks(socket, :edit, bookmarks_params) do
    case Core.update_bookmarks(socket.assigns.bookmarks, bookmarks_params) do
      {:ok, _bookmarks} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bookmarks updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_bookmarks(socket, :new, bookmarks_params) do
    case Core.create_bookmarks(bookmarks_params) do
      {:ok, _bookmarks} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bookmarks created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
