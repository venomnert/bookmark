defmodule BookmarkWeb.ModalComponent do
  use BookmarkWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div class="phx-modal-content mt-20 md-mt:auto">
      <%= live_patch raw("Back"), to: @return_to, class: "bg-blue-500 font-bold hover:bg-blue-700 px-4 py-2 rounded text-white" %>
      <%= live_component @socket, @component, @opts %>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
