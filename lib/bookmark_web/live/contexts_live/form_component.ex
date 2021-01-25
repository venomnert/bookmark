defmodule BookmarkWeb.ContextsLive.FormComponent do
  use BookmarkWeb, :live_component

  alias Bookmark.Core

  @impl true
  def update(%{contexts: context} = assigns, socket) do
    changeset = Core.change_context(context)

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
     |> assign(:changeset, changeset)
     |> assign(:media_changeset, changeset)
     |> assign(:context, context)}
  end

  @impl true
  def handle_event("validate", %{"contexts" => context_params}, socket) do
    changeset =
      socket.assigns.contexts
      |> Core.change_context(context_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("remove-media", %{"ref" => ref}, socket) do
    # url = Path.join("priv/static", "#{ref}")

    updated_media_urls =
      socket.assigns.contexts.media
      |> Enum.filter(&(&1 != ref))

    # File.rm!(url)

    case Core.update_context(socket.assigns.contexts, %{}, updated_media_urls) do
      {:ok, _context} ->
        consume_media(socket)

        {:noreply,
         socket
         |> put_flash(:info, "Context media updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("save", %{"contexts" => context_params}, socket) do
    save_context(socket, socket.assigns.action, context_params)
  end

  defp save_context(socket, :edit, context_params) do
    urls = put_media(socket)

    case Core.update_context(socket.assigns.contexts, context_params, urls) do
      {:ok, _context} ->
        consume_media(socket)

        {:noreply,
         socket
         |> put_flash(:info, "Context updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_context(socket, :new, context_params) do
    case Core.create_context(context_params) do
      {:ok, _context} ->
        {:noreply,
         socket
         |> put_flash(:info, "Context created successfully")
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
end
