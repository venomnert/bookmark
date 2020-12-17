defmodule Bookmark.CoreTest do
  use Bookmark.DataCase

  alias Bookmark.Core

  describe "bookmark" do
    alias Bookmark.Core.Bookmarks

    @valid_attrs %{name: "some name", url: "some url"}
    @update_attrs %{name: "some updated name", url: "some updated url"}
    @invalid_attrs %{name: nil, url: nil}

    def bookmarks_fixture(attrs \\ %{}) do
      {:ok, bookmarks} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_bookmarks()

      bookmarks
    end

    test "list_bookmark/0 returns all bookmark" do
      bookmarks = bookmarks_fixture()
      assert Core.list_bookmark() == [bookmarks]
    end

    test "get_bookmarks!/1 returns the bookmarks with given id" do
      bookmarks = bookmarks_fixture()
      assert Core.get_bookmarks!(bookmarks.id) == bookmarks
    end

    test "create_bookmarks/1 with valid data creates a bookmarks" do
      assert {:ok, %Bookmarks{} = bookmarks} = Core.create_bookmarks(@valid_attrs)
      assert bookmarks.name == "some name"
      assert bookmarks.url == "some url"
    end

    test "create_bookmarks/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_bookmarks(@invalid_attrs)
    end

    test "update_bookmarks/2 with valid data updates the bookmarks" do
      bookmarks = bookmarks_fixture()
      assert {:ok, %Bookmarks{} = bookmarks} = Core.update_bookmarks(bookmarks, @update_attrs)
      assert bookmarks.name == "some updated name"
      assert bookmarks.url == "some updated url"
    end

    test "update_bookmarks/2 with invalid data returns error changeset" do
      bookmarks = bookmarks_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_bookmarks(bookmarks, @invalid_attrs)
      assert bookmarks == Core.get_bookmarks!(bookmarks.id)
    end

    test "delete_bookmarks/1 deletes the bookmarks" do
      bookmarks = bookmarks_fixture()
      assert {:ok, %Bookmarks{}} = Core.delete_bookmarks(bookmarks)
      assert_raise Ecto.NoResultsError, fn -> Core.get_bookmarks!(bookmarks.id) end
    end

    test "change_bookmarks/1 returns a bookmarks changeset" do
      bookmarks = bookmarks_fixture()
      assert %Ecto.Changeset{} = Core.change_bookmarks(bookmarks)
    end
  end

  describe "contexts" do
    alias Bookmark.Core.Contexts

    @valid_attrs %{picture: "some picture", text: "some text", video: "some video"}
    @update_attrs %{picture: "some updated picture", text: "some updated text", video: "some updated video"}
    @invalid_attrs %{picture: nil, text: nil, video: nil}

    def context_fixture(attrs \\ %{}) do
      {:ok, context} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_context()

      context
    end

    test "list_contexts/0 returns all contexts" do
      context = context_fixture()
      assert Core.list_contexts() == [context]
    end

    test "get_context!/1 returns the context with given id" do
      context = context_fixture()
      assert Core.get_context!(context.id) == context
    end

    test "create_context/1 with valid data creates a context" do
      assert {:ok, %Contexts{} = context} = Core.create_context(@valid_attrs)
      assert context.picture == "some picture"
      assert context.text == "some text"
      assert context.video == "some video"
    end

    test "create_context/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_context(@invalid_attrs)
    end

    test "update_context/2 with valid data updates the context" do
      context = context_fixture()
      assert {:ok, %Contexts{} = context} = Core.update_context(context, @update_attrs)
      assert context.picture == "some updated picture"
      assert context.text == "some updated text"
      assert context.video == "some updated video"
    end

    test "update_context/2 with invalid data returns error changeset" do
      context = context_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_context(context, @invalid_attrs)
      assert context == Core.get_context!(context.id)
    end

    test "delete_context/1 deletes the context" do
      context = context_fixture()
      assert {:ok, %Contexts{}} = Core.delete_context(context)
      assert_raise Ecto.NoResultsError, fn -> Core.get_context!(context.id) end
    end

    test "change_context/1 returns a context changeset" do
      context = context_fixture()
      assert %Ecto.Changeset{} = Core.change_context(context)
    end
  end
end
