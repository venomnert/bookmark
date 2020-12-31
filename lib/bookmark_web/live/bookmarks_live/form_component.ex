defmodule BookmarkWeb.BookmarksLive.FormComponent do
  use BookmarkWeb, :live_component

  alias Bookmark.Core
  alias Bookmark.Core.{Contexts}
  alias Ecto

  @impl true
  def update(%{bookmarks: bookmarks, action: :new} = assigns, socket) do
    bookmark_changeset = Core.change_bookmarks(bookmarks)
    contexts_list = Core.list_contexts()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, bookmark_changeset)
     |> assign(:context_disabled, false)
     |> assign(contexts: contexts_list)}
  end

  @impl true
  def update(%{bookmarks: bookmarks, action: :edit} = assigns, socket) do
    bookmarks_changeset = Core.change_bookmarks(bookmarks)
    contexts_list = Core.list_contexts()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, bookmarks_changeset)
     |> assign(:context_disabled, false)
     |> assign(contexts: contexts_list)
    }
  end

  @impl true
  def handle_event(
        "validate",
        %{"bookmarks" => %{"context_id" => context_id} = bookmarks_params},
        %{assigns: %{action: :new}} = socket
      ) do
    context_id
    |> normalize_context_id()
    |> case do
      0 ->
        updated_bookmarks_params =
          bookmarks_params
          |> Map.put("contexts", %{"0" => %{"picture" => "", "text" => "", "video" => ""}})

        {updated_bookmark_changeset, update_context_changeset} =
          validate_bookmark_changeset(socket, %{"bookmarks" => updated_bookmarks_params})

        {:noreply,
         socket
         |> assign(:changeset, updated_bookmark_changeset)}

      id when id > 0 ->
        bookmark_changeset =
          socket.assigns.bookmarks
          |> Core.change_bookmarks(bookmarks_params)
          |> Map.put(:action, :validate)

        {:noreply,
         socket
         |> assign(:changeset, bookmark_changeset)}
    end

    # TODO - when select is selected remove context changeset
  end

  @impl true
  def handle_event("validate", bookmarks_params, %{assigns: %{action: :edit}} = socket) do
    bookmark_changeset = validate_bookmark_changeset(socket, bookmarks_params)

    context_disabled =
      bookmarks_params["bookmarks"]["context_id"]
      |> normalize_context_id()
      |> case do
        0 -> false
        id when id > 0 -> true
      end

    {:noreply,
     socket
     |> assign(:changeset, bookmark_changeset)
     |> assign(:context_disabled, context_disabled)
    }

    # TODO - when select is selected remove context changeset
  end

  def handle_event(
        "save",
        %{"bookmarks" => %{"context_id" => context_id} = bookmarks_params},
        socket
      ) do
    casted_context_id = normalize_context_id(context_id)

    updated_bookmarks_params =
      bookmarks_params
      |> Map.put("context_id", casted_context_id)

    save_bookmarks(socket, socket.assigns.action, updated_bookmarks_params)
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

  defp save_bookmarks(socket, :edit, bookmarks_params) do
    case Core.update_bookmarks(socket.assigns.bookmarks, bookmarks_params, :edit) do
      {:ok, _bookmarks} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bookmarks updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp validate_bookmark_changeset(%{assigns: %{action: :new}} = socket, %{
         "bookmarks" => bookmarks_params
       }) do
    context =
      %Contexts{}
      |> Core.change_context(bookmarks_params["contexts"]["0"])

    bookmark_changeset =
      socket.assigns.bookmarks
      |> Core.change_bookmarks(bookmarks_params)
      |> Map.put(:action, :validate)
      |> Ecto.Changeset.put_assoc(:contexts, [context])

    update_context_changeset =
      bookmark_changeset.changes.contexts
      |> List.first()
      |> Map.put(:action, :validate)

    updated_bookmark_changeset =
      bookmark_changeset
      |> Map.put(:changes, %{contexts: [update_context_changeset]})

    {updated_bookmark_changeset, update_context_changeset}
  end

  defp validate_bookmark_changeset(%{assigns: %{action: :edit}} = socket, %{"bookmarks" => bookmarks_params}) do
    socket.assigns.bookmarks
    |> Core.change_bookmarks(bookmarks_params)
    |> Map.put(:action, :validate)
    |> Ecto.Changeset.cast_assoc(:contexts, with: &Core.change_context/2)
  end

  defp normalize_context_id(""), do: 0
  defp normalize_context_id(context_id), do: String.to_integer(context_id)
end
