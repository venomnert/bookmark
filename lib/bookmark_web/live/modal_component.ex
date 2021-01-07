defmodule BookmarkWeb.ModalComponent do
  use BookmarkWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div class="phx-modal-content mt-20 md-mt:auto">
      <%= live_component @socket, @component, @opts %>
      <%= live_patch raw("Back"), to: @return_to, class: "bg-blue-600 block focus:outline-none font-medium hover:bg-blue-900 hover:shadow-none mt-6 mx-auto py-3 shadow-lg text-center text-white tracking-widest uppercase w-2/5" %>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
