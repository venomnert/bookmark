defmodule BookmarkWeb.BookmarksLiveTest do
  use BookmarkWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Bookmark.Core

  @create_attrs %{name: "some name", url: "some url"}
  @update_attrs %{name: "some updated name", url: "some updated url"}
  @invalid_attrs %{name: nil, url: nil}

  defp fixture(:bookmarks) do
    {:ok, bookmarks} = Core.create_bookmarks(@create_attrs)
    bookmarks
  end

  defp create_bookmarks(_) do
    bookmarks = fixture(:bookmarks)
    %{bookmarks: bookmarks}
  end

  describe "Index" do
    setup [:create_bookmarks]

    test "lists all bookmark", %{conn: conn, bookmarks: bookmarks} do
      {:ok, _index_live, html} = live(conn, Routes.bookmarks_index_path(conn, :index))

      assert html =~ "Listing Bookmark"
      assert html =~ bookmarks.name
    end

    test "saves new bookmarks", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.bookmarks_index_path(conn, :index))

      assert index_live |> element("a", "New Bookmarks") |> render_click() =~
               "New Bookmarks"

      assert_patch(index_live, Routes.bookmarks_index_path(conn, :new))

      assert index_live
             |> form("#bookmarks-form", bookmarks: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#bookmarks-form", bookmarks: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.bookmarks_index_path(conn, :index))

      assert html =~ "Bookmarks created successfully"
      assert html =~ "some name"
    end

    test "updates bookmarks in listing", %{conn: conn, bookmarks: bookmarks} do
      {:ok, index_live, _html} = live(conn, Routes.bookmarks_index_path(conn, :index))

      assert index_live |> element("#bookmarks-#{bookmarks.id} a", "Edit") |> render_click() =~
               "Edit Bookmarks"

      assert_patch(index_live, Routes.bookmarks_index_path(conn, :edit, bookmarks))

      assert index_live
             |> form("#bookmarks-form", bookmarks: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#bookmarks-form", bookmarks: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.bookmarks_index_path(conn, :index))

      assert html =~ "Bookmarks updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes bookmarks in listing", %{conn: conn, bookmarks: bookmarks} do
      {:ok, index_live, _html} = live(conn, Routes.bookmarks_index_path(conn, :index))

      assert index_live |> element("#bookmarks-#{bookmarks.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bookmarks-#{bookmarks.id}")
    end
  end

  describe "Show" do
    setup [:create_bookmarks]

    test "displays bookmarks", %{conn: conn, bookmarks: bookmarks} do
      {:ok, _show_live, html} = live(conn, Routes.bookmarks_show_path(conn, :show, bookmarks))

      assert html =~ "Show Bookmarks"
      assert html =~ bookmarks.name
    end

    test "updates bookmarks within modal", %{conn: conn, bookmarks: bookmarks} do
      {:ok, show_live, _html} = live(conn, Routes.bookmarks_show_path(conn, :show, bookmarks))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Bookmarks"

      assert_patch(show_live, Routes.bookmarks_show_path(conn, :edit, bookmarks))

      assert show_live
             |> form("#bookmarks-form", bookmarks: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#bookmarks-form", bookmarks: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.bookmarks_show_path(conn, :show, bookmarks))

      assert html =~ "Bookmarks updated successfully"
      assert html =~ "some updated name"
    end
  end
end
