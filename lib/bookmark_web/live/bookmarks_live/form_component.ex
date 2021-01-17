defmodule BookmarkWeb.BookmarksLive.FormComponent do
  use BookmarkWeb, :live_component

  alias Bookmark.Core
  alias Bookmark.Core.{Contexts}
  alias Ecto

  @impl true
  def update(%{bookmarks: bookmarks, action: :new} = assigns, socket) do
    bookmark_changeset = Core.change_bookmarks(bookmarks)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, bookmark_changeset)
     |> assign(:context_disabled, false)
     |> assign(context_create: false)
    }
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
     |> assign(context_create: true)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"bookmarks" => %{"context_create" => "false"} = bookmarks_params},
        %{assigns: %{action: :new}} = socket
      ) do
    socket = assign(socket, :context_create, false)

    bookmarks_params
    |> Map.get("context_id")
    |> normalize_context_id()
    |> case do
      nil ->
        updated_bookmark_changeset =
          validate_bookmark_changeset(socket, %{"bookmarks" => bookmarks_params}, :bookmark)

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
  def handle_event(
        "validate",
        %{"bookmarks" => %{"context_create" => "true"} = bookmarks_params},
        %{assigns: %{action: :new}} = socket
      ) do

    contexts_list = Core.list_contexts()

    socket = socket
            |> assign(:context_create, true)
            |> assign(contexts: contexts_list)

    bookmarks_params
    |> Map.get("context_id")
    |> normalize_context_id()
    |> case do
      nil ->
        updated_bookmark_changeset =
          validate_bookmark_changeset(socket, %{"bookmarks" => bookmarks_params})

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
      bookmarks_params["bookmarks"]["contexts"]["0"]["id"]
      |> normalize_context_id()
      |> case do
        nil -> true
        id when id > 0 -> false
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
    updated_bookmarks_params =
      Map.put(bookmarks_params, "context_id", normalize_context_id(context_id))

    save_bookmarks(socket, socket.assigns.action, updated_bookmarks_params)
  end

  def handle_event("save", %{"bookmarks" => bookmarks_params}, socket) do
    save_bookmarks(socket, socket.assigns.action, bookmarks_params)
  end

  defp save_bookmarks(socket, :new, bookmarks_params) do
    {type, updated_bookmarks_params} = check_bookmarks_params(bookmarks_params)

    case Core.create_bookmarks(updated_bookmarks_params, type) do
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
    bookmarks_params["contexts"]["0"]
    |> case do
      nil ->
        socket.assigns.bookmarks
        |> Core.change_bookmarks(bookmarks_params, :empty_context)
        |> Map.put(:action, :validate)

      _ ->
        validate_bookmark_changeset(socket, %{"bookmarks" => bookmarks_params}, :filled_context)
    end
  end

  defp validate_bookmark_changeset(%{assigns: %{action: :edit}} = socket, %{
         "bookmarks" => bookmarks_params
       }) do
    socket.assigns.bookmarks
    |> Core.change_bookmarks(bookmarks_params, :filled_context)
    |> Map.put(:action, :validate)
    |> IO.inspect(label: "RESULTS")
  end

  defp validate_bookmark_changeset(
         %{assigns: %{action: :new}} = socket,
         %{"bookmarks" => bookmarks_params},
         :bookmark
       ) do
    socket.assigns.bookmarks
    |> Core.change_bookmarks(bookmarks_params)
    |> Map.put(:action, :validate)
  end

  defp validate_bookmark_changeset(
         %{assigns: %{action: :new}} = socket,
         %{"bookmarks" => bookmarks_params},
         :filled_context
       ) do
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

    updated_bookmark_changeset
  end

  defp check_bookmarks_params(bookmarks_params) do
    context_id = bookmarks_params |> Map.get("context_id") |> normalize_context_id()
    context_params = bookmarks_params |> get_in(["contexts", "0"])

    cond do
      context_id == nil && context_params == nil ->
        {:bookmark, bookmarks_params}

      is_integer(context_id) == true && context_id > 0 ->
        {:bookmark_selected_context, bookmarks_params}

      validate_contexts_params(context_params) == true || validate_contexts_params(context_params) == false ->
        {:bookmark_custom_context, bookmarks_params}

      true ->
        {:bookmark, bookmarks_params}
    end
  end

  defp normalize_context_id(context_id) do
    cond do
      is_integer(context_id) -> context_id
      context_id == "" -> nil
      is_nil(context_id) -> nil
      true -> String.to_integer(context_id)
    end
  end

  defp validate_contexts_params(context_params) do
    context_params
    |> Map.values()
    |> convert_empty_to_falsy()
    |> Enum.any?()
  end

  defp convert_empty_to_falsy(values) do
    values
    |> Enum.reduce([], &convert_to_nill(&1, &2))
  end

  defp convert_to_nill("", acc), do: [nil] ++ acc
  defp convert_to_nill(val, acc), do: [val] ++ acc
end
