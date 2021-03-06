defmodule BookmarkWeb.BookmarksLive.FormComponent do
  use BookmarkWeb, :live_component

  alias Bookmark.Core
  alias Bookmark.Core.{Contexts}
  alias Ecto

  # Testing form component - custom context
  @impl true
  def update(
        %{bookmarks: bookmarks, action: :test_custom, bookmarks_params: bookmarks_params} =
          assigns,
        socket
      ) do
    bookmark_changeset =
      bookmarks
      |> Core.change_bookmarks(bookmarks_params, :empty_context)
      |> Map.put(:action, :validate)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, bookmark_changeset)
     |> assign(:context_disabled, false)
     |> assign(context_create: true)
     |> assign(contexts: [])}
  end

  # Testing form component - existing context
  @impl true
  def update(
        %{bookmarks: bookmarks, action: :test_existing, bookmarks_params: bookmarks_params} =
          assigns,
        socket
      ) do
    bookmark_changeset =
      bookmarks
      |> Core.change_bookmarks(bookmarks_params)
      |> Map.put(:action, :validate)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, bookmark_changeset)
     |> assign(:context_disabled, false)
     |> assign(context_create: true)
     |> assign(contexts: assigns.contexts)}
  end

  # Testing form input - custom context
  @impl true
  def update(%{bookmarks: bookmarks, action: :test_custom} = assigns, socket) do
    bookmark_changeset =
      bookmarks
      |> Core.change_bookmarks(%{}, :empty_context)
      |> Map.put(:action, :validate)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, bookmark_changeset)
     |> assign(:context_disabled, false)
     |> assign(context_create: true)
     |> assign(contexts: [])}
  end

  # Testing form input - existing context
  @impl true
  def update(%{bookmarks: bookmarks, action: :test_existing} = assigns, socket) do
    bookmark_changeset =
      bookmarks
      |> Core.change_bookmarks()
      |> Map.put(:action, :validate)

    context = Core.list_contexts() |> List.first()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, bookmark_changeset)
     |> assign(:context_disabled, false)
     |> assign(context_create: true)
     |> assign(contexts: [context])}
  end

  @impl true
  def update(%{bookmarks: bookmarks, action: :new} = assigns, socket) do
    bookmark_changeset = Core.change_bookmarks(bookmarks)

    socket =
      socket
      |> allow_upload(:media,
        accept: ~w(.png .jpeg .jpg .wav .mp4 .mpg .wmv .avi),
        max_entries: 5,
        max_file_size: 100_000_000
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, bookmark_changeset)
     |> assign(:context_disabled, false)
     |> assign(context_create: false)}
  end

  @impl true
  def update(%{bookmarks: bookmarks, action: :edit} = assigns, socket) do
    bookmarks_changeset = Core.change_bookmarks(bookmarks)
    contexts_list = Core.list_contexts()
    new_context_changeset = Core.change_context(%Contexts{})

    socket =
      socket
      |> allow_upload(:media,
        accept: ~w(.png .jpeg .jpg .wav .mp4 .mpg .wmv .avi),
        max_entries: 5,
        max_file_size: 100_000_000
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, bookmarks_changeset)
     |> assign(:context_disabled, false)
     |> assign(contexts: contexts_list)
     |> assign(context_create: true)
     |> assign(context_changeset: new_context_changeset)}
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
  end

  @impl true
  def handle_event(
        "validate",
        %{"bookmarks" => %{"context_create" => "true"} = bookmarks_params},
        %{assigns: %{action: :new}} = socket
      ) do
    contexts_list = Core.list_contexts()

    socket =
      socket
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
  end

  @impl true
  def handle_event(
        "validate",
        %{"bookmarks" => bookmarks_params},
        %{assigns: %{action: :edit}} = socket
      ) do
    context_disabled =
      bookmarks_params
      |> get_in(["contexts", "0", "id"])
      |> normalize_context_id()
      |> case do
        nil -> true
        id when id > 0 -> false
      end

    bookmark_changeset =
      socket.assigns.bookmarks
      |> Core.change_bookmarks(bookmarks_params, :selected_context)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, bookmark_changeset)
     |> assign(:context_disabled, context_disabled)}
  end

  @impl true
  def handle_event(
        "validate-add-context",
        %{"contexts" => contexts_params},
        %{assigns: %{action: :edit}} = socket
      ) do
    contexts_params
    |> Map.get("context_id")
    |> normalize_context_id()
    |> case do
      nil ->
        updated_context_changeset =
          Core.change_context(%Contexts{}, contexts_params) |> Map.put(:action, :validate)

        {:noreply,
         socket
         |> assign(:context_changeset, updated_context_changeset)}

      id when id > 0 ->
        updated_context_changeset =
          id
          |> Core.get_context!()
          |> Core.change_context(contexts_params)
          |> Map.put(:action, :validate)

        {:noreply,
         socket
         |> assign(:context_changeset, updated_context_changeset)}
    end
  end

  @impl true
  def handle_event("remove-media", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :media, ref)}
  end

  @impl true
  def handle_event("delete-context", %{"id" => context_id}, socket) do
    updated_bookmark =
      socket.assigns.bookmarks |> Core.delete_context_from_bookmark(String.to_integer(context_id))

    {:noreply, assign(socket, :bookmarks, updated_bookmark)}
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

  def handle_event(
        "add-context",
        %{"contexts" => %{"context_id" => context_id} = contexts_params},
        socket
      ) do
    contexts_params = contexts_params |> Map.put("context_id", normalize_context_id(context_id))
    add_context(socket, socket.assigns.action, contexts_params)
  end

  # Testing form submit - custom context
  defp save_bookmarks(socket, :test_custom, bookmarks_params) do
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

  # Testing form submit - existing context
  defp save_bookmarks(socket, :test_existing, bookmarks_params) do
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

  defp save_bookmarks(socket, :new, bookmarks_params) do
    urls = put_media(socket)

    {type, updated_bookmarks_params} = check_bookmarks_params(bookmarks_params)

    case Core.create_bookmarks(updated_bookmarks_params, type, urls) do
      {:ok, _bookmarks} ->
        consume_media(socket)

        {:noreply,
         socket
         |> put_flash(:info, "Bookmarks created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_bookmarks(socket, :edit, bookmarks_params) do

    case Core.update_bookmarks(socket.assigns.bookmarks, bookmarks_params) do
      {:ok, _bookmarks} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bookmarks updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp consume_media(socket) do
    consume_uploaded_entries(socket, :media, fn meta, entry ->
      dest = Path.join("priv/static/uploads", "#{entry.uuid}.#{ext(entry)}")
      File.cp!(meta.path, dest)
      IO.inspect(label: "LOADED MEDIA")
    end)

    :ok
  end

  defp add_context(socket, :edit, contexts_params) do
    urls = put_media(socket)

    case Core.add_context(socket.assigns.bookmarks, contexts_params, urls) do
      {:ok, _bookmarks} ->
        consume_media(socket)

        {:noreply,
         socket
         |> put_flash(:info, "Bookmarks updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp put_media(socket) do
    {media_completed, []} = uploaded_entries(socket, :media)

    media_urls =
      for entry <- media_completed do
        Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}")
      end

    media_urls
  end

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
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
        validate_bookmark_changeset(socket, %{"bookmarks" => bookmarks_params}, :selected_context)
    end
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
         :selected_context
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

      validate_contexts_params(context_params) == true ||
          validate_contexts_params(context_params) == false ->
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
