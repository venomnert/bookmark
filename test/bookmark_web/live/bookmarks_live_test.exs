defmodule BookmarkWeb.BookmarksLiveTest do
  use BookmarkWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Bookmark.Repo
  alias Bookmark.Core
  alias Bookmark.Accounts
  alias BookmarkWeb.UserAuth

  @create_attrs %{name: "some name", url: "some url"}
  @valid_context_attrs %{picture: "some picture", text: "some text", video: "some video"}
  @create_attrs_with_context %{
    contexts: %{
      "0" => @valid_context_attrs
    },
    name: "some name",
    url: "some url"
  }

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

    test "saves new bookmarks with new contexts", %{conn: conn, bookmarks: bookmarks} do
      bookmarks = bookmarks |> Repo.preload(:contexts)

      assert render_component(BookmarkWeb.BookmarksLive.FormComponent,
               id: bookmarks.id || :new_bookmark,
               title: "New bookmarks",
               action: :new_test,
               create_bookmark: :empty_context,
               bookmarks_params: @create_attrs_with_context,
               bookmarks: bookmarks,
               return_to: Routes.bookmarks_index_path(conn, :index)
             ) =~ "existing contexts"

      {:ok, view, _} = live(conn, Routes.bookmarks_new_path(conn, :new_test))

      view
      |> form("#bookmarks-form", bookmarks: @create_attrs_with_context)
      |> render_submit()
      |> follow_redirect(conn, Routes.bookmarks_index_path(conn, :index))

      context =
        Core.list_bookmark_with_context()
        |> List.last()
        |> Map.get(:contexts)
        |> List.first()

      assert context.text == "some text"
      assert context.picture == "some picture"
      assert context.video == "some video"
    end

    test "saves new bookmarks with existing contexts", %{conn: conn, bookmarks: bookmarks} do
      bookmarks = bookmarks |> Repo.preload(:contexts)
      {:ok, new_context} = Core.create_context(@valid_context_attrs)
      updated_create_attrs = Map.put(@create_attrs, "context_id", Integer.to_string(new_context.id))

      assert render_component(BookmarkWeb.BookmarksLive.FormComponent,
               id: bookmarks.id || :new_bookmark,
               title: "New bookmarks",
               action: :new_test,
               create_bookmark: :selected_context,
               bookmarks_params: @create_attrs,
               contexts: [new_context],
               bookmarks: bookmarks,
               return_to: Routes.bookmarks_index_path(conn, :index)
             ) =~ new_context.text

      {:ok, view, _} = live(conn, Routes.bookmarks_new_path(conn, :new_test_select))

      view
      |> form("#bookmarks-form", bookmarks: updated_create_attrs)
      |> render_submit()
      |> follow_redirect(conn, Routes.bookmarks_index_path(conn, :index))

      selected_context =
        Core.list_bookmark_with_context()
        |> List.last()
        |> Map.get(:contexts)
        |> List.first()

      assert new_context == selected_context
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
end
