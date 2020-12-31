defmodule BookmarkWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `BookmarkWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, BookmarkWeb.BookmarksLive.FormComponent,
        id: @bookmarks.id || :new,
        action: @live_action,
        bookmarks: @bookmarks,
        return_to: Routes.bookmarks_index_path(@socket, :index) %>
  """
  def live_modal_bookmark(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal_bookmark, return_to: path, component: component, opts: opts]
    live_component(socket, BookmarkWeb.ModalComponent, modal_opts)
  end
  def live_modal_context(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal_context, return_to: path, component: component, opts: opts]
    live_component(socket, BookmarkWeb.ModalComponent, modal_opts)
  end
end
