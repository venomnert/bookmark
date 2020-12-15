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
end
