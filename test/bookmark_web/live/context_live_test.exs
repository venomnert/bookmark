defmodule BookmarkWeb.ContextLiveTest do
  use BookmarkWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Bookmark.Core

  @create_attrs %{picture: "some picture", text: "some text", video: "some video"}
  @update_attrs %{picture: "some updated picture", text: "some updated text", video: "some updated video"}
  @invalid_attrs %{picture: nil, text: nil, video: nil}

  defp fixture(:context) do
    {:ok, context} = Core.create_context(@create_attrs)
    context
  end

  defp create_context(_) do
    context = fixture(:context)
    %{context: context}
  end

  describe "Index" do
    setup [:create_context]

    test "lists all contexts", %{conn: conn, context: context} do
      {:ok, _index_live, html} = live(conn, Routes.context_index_path(conn, :index))

      assert html =~ "Listing Contexts"
      assert html =~ context.picture
    end

    test "saves new context", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.context_index_path(conn, :index))

      assert index_live |> element("a", "New Context") |> render_click() =~
               "New Context"

      assert_patch(index_live, Routes.context_index_path(conn, :new))

      assert index_live
             |> form("#context-form", context: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#context-form", context: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.context_index_path(conn, :index))

      assert html =~ "Context created successfully"
      assert html =~ "some picture"
    end

    test "updates context in listing", %{conn: conn, context: context} do
      {:ok, index_live, _html} = live(conn, Routes.context_index_path(conn, :index))

      assert index_live |> element("#context-#{context.id} a", "Edit") |> render_click() =~
               "Edit Context"

      assert_patch(index_live, Routes.context_index_path(conn, :edit, context))

      assert index_live
             |> form("#context-form", context: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#context-form", context: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.context_index_path(conn, :index))

      assert html =~ "Context updated successfully"
      assert html =~ "some updated picture"
    end

    test "deletes context in listing", %{conn: conn, context: context} do
      {:ok, index_live, _html} = live(conn, Routes.context_index_path(conn, :index))

      assert index_live |> element("#context-#{context.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#context-#{context.id}")
    end
  end

  describe "Show" do
    setup [:create_context]

    test "displays context", %{conn: conn, context: context} do
      {:ok, _show_live, html} = live(conn, Routes.context_show_path(conn, :show, context))

      assert html =~ "Show Context"
      assert html =~ context.picture
    end

    test "updates context within modal", %{conn: conn, context: context} do
      {:ok, show_live, _html} = live(conn, Routes.context_show_path(conn, :show, context))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Context"

      assert_patch(show_live, Routes.context_show_path(conn, :edit, context))

      assert show_live
             |> form("#context-form", context: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#context-form", context: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.context_show_path(conn, :show, context))

      assert html =~ "Context updated successfully"
      assert html =~ "some updated picture"
    end
  end
end
