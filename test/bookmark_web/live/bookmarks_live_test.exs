defmodule BookmarkWeb.BookmarksLiveTest do
  use BookmarkWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Bookmark.Core
  alias Bookmark.Accounts
  alias BookmarkWeb.UserAuth

  @create_attrs %{name: "some name", url: "some url"}
  @update_attrs %{name: "some updated name", url: "some updated url"}
  @invalid_attrs %{name: nil, url: nil}

  defp fixture(:bookmarks) do
    {:ok, bookmarks} = Core.create_bookmarks(@create_attrs, :bookmark)
    bookmarks
  end

  defp create_bookmarks(_) do
    bookmarks = fixture(:bookmarks)
    user_params = %{"email" => "test1@gmail.com", "password" => "123456789012"}
    {:ok, user} = Accounts.register_user(user_params)

    conn =
      session_conn()
      |> Plug.Test.init_test_session(%{})
      |> UserAuth.log_in_user(user)
      |> Map.put(:state, :unset)
      |> Map.put(:status, nil)

    %{bookmarks: bookmarks, conn: conn}
  end

  describe "Index Bookmark Only" do
    setup [:create_bookmarks]

    test "lists all bookmark", %{conn: conn, bookmarks: bookmarks} do
      {:ok, _index_live, html} = live(conn, Routes.bookmarks_index_path(conn, :index))

      assert html =~ "Listing Bookmark"
      assert html =~ bookmarks.name
    end

    test "saves new bookmarks", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.bookmarks_index_path(conn, :index))

      assert index_live
            |> element("a[href*='bookmark/new']", "New Bookmarks")
            |> has_element?()

      {:ok, new_live, _html} = live(conn, Routes.bookmarks_new_path(conn, :new))

      result =
        new_live
        |> form("#bookmarks-form", bookmarks: @invalid_attrs)
        |> render_change()

      assert result =~ "can&apos;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#bookmarks-form", bookmarks: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.bookmarks_index_path(conn, :index))

      assert html =~ "Bookmarks created successfully"
      assert html =~ "some name"
    end

    test "updates bookmarks in listing", %{conn: conn, bookmarks: bookmarks} do
      {:ok, index_live, _html} = live(conn, Routes.bookmarks_index_path(conn, :index))
      {:ok, edit_live, _html} = live(conn, Routes.bookmarks_edit_path(conn, :edit, bookmarks))

      assert index_live
             |> element("a[href*='bookmark/#{bookmarks.id}/edit']", "Edit")
             |> has_element?()

      assert edit_live
             |> render_patch("bookmark/#{bookmarks.id}/edit") =~ "Edit Bookmarks"

      assert edit_live
             |> form("#bookmarks-form", bookmarks: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        edit_live
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

  describe "Show Bookmark Only" do
    setup [:create_bookmarks]

    test "displays bookmarks", %{conn: conn, bookmarks: bookmarks} do
      {:ok, _show_live, html} = live(conn, Routes.bookmarks_show_path(conn, :show, bookmarks))

      assert html =~ "Show Bookmark"
      assert html =~ bookmarks.name
    end

    test "updates bookmarks within modal", %{conn: conn, bookmarks: bookmarks} do
      {:ok, show_live, _html} = live(conn, Routes.bookmarks_show_path(conn, :show, bookmarks))

      assert show_live
             |> element("a[href*='bookmark/#{bookmarks.id}/edit']", "Edit")
             |> has_element?()
    end
  end

  describe "Index Bookmark with Context" do
    setup [:create_bookmarks]

    test "lists all bookmark", %{conn: conn, bookmarks: bookmarks} do
      {:ok, _index_live, html} = live(conn, Routes.bookmarks_index_path(conn, :index))

      assert html =~ "Listing Bookmark"
      assert html =~ bookmarks.name
    end

    test "saves new bookmarks", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.bookmarks_index_path(conn, :index))

      assert index_live
             |> element("a[href*='bookmark/new']", "New Bookmarks")
             |> has_element?()

      {:ok, new_live, _html} = live(conn, Routes.bookmarks_new_path(conn, :new))

      result =
        new_live
        |> form("#bookmarks-form", bookmarks: @invalid_attrs)
        |> render_change()

      assert result =~ "can&apos;t be blank"

      # {:ok, _, html} =
      #   new_live
      #   |> form("#bookmarks-form", bookmarks: @create_attrs)
      #   |> render_submit()
      #   |> follow_redirect(conn, Routes.bookmarks_index_path(conn, :index))

      # assert html =~ "Bookmarks created successfully"
      # assert html =~ "some name"
    end

    # test "updates bookmarks in listing", %{conn: conn, bookmarks: bookmarks} do
    #   {:ok, index_live, _html} = live(conn, Routes.bookmarks_index_path(conn, :index))
    #   {:ok, edit_live, _html} = live(conn, Routes.bookmarks_edit_path(conn, :edit, bookmarks))

    #   assert index_live
    #          |> element("a[href*='bookmark/#{bookmarks.id}/edit']", "Edit")
    #          |> has_element?()

    #   assert edit_live
    #          |> render_patch("bookmark/#{bookmarks.id}/edit") =~ "Edit Bookmarks"

    #   assert edit_live
    #          |> form("#bookmarks-form", bookmarks: @invalid_attrs)
    #          |> render_change() =~ "can&apos;t be blank"

    #   {:ok, _, html} =
    #     edit_live
    #     |> form("#bookmarks-form", bookmarks: @update_attrs)
    #     |> render_submit()
    #     |> follow_redirect(conn, Routes.bookmarks_index_path(conn, :index))

    #   assert html =~ "Bookmarks updated successfully"
    #   assert html =~ "some updated name"
    # end

    # test "deletes bookmarks in listing", %{conn: conn, bookmarks: bookmarks} do
    #   {:ok, index_live, _html} = live(conn, Routes.bookmarks_index_path(conn, :index))

    #   assert index_live |> element("#bookmarks-#{bookmarks.id} a", "Delete") |> render_click()
    #   refute has_element?(index_live, "#bookmarks-#{bookmarks.id}")
    # end
  end

  # describe "Show Bookmark with Context" do
  #   setup [:create_bookmarks]

  #   test "displays bookmarks", %{conn: conn, bookmarks: bookmarks} do
  #     {:ok, _show_live, html} = live(conn, Routes.bookmarks_show_path(conn, :show, bookmarks))

  #     assert html =~ "Show Bookmark"
  #     assert html =~ bookmarks.name
  #   end

  #   test "updates bookmarks within modal", %{conn: conn, bookmarks: bookmarks} do
  #     {:ok, show_live, _html} = live(conn, Routes.bookmarks_show_path(conn, :show, bookmarks))

  #     assert show_live
  #            |> element("a[href*='bookmark/#{bookmarks.id}/edit']", "Edit")
  #            |> has_element?()
  #   end
  # end
end
