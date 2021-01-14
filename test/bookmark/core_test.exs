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
        |> Core.create_bookmarks(:bookmark)

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
      assert {:ok, %Bookmarks{} = bookmarks} = Core.create_bookmarks(@valid_attrs, :bookmark)
      assert bookmarks.name == "some name"
      assert bookmarks.url == "some url"
    end

    test "create_bookmarks/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_bookmarks(@invalid_attrs, :bookmark)
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

  describe "bookmark_context" do
    alias Bookmark.Core.{Bookmarks, Contexts}

    @valid_attrs_bookmarks %{"name" => "some name", "url" => "some url"}
    @update_attrs_bookmarks %{"name" => "some updated name", "url" => "some updated url"}
    @invalid_attrs_bookmarks %{"name" => nil, "url" => nil}

    @valid_attrs_contexts %{"picture" => "some picture", "text" => "some text", "video" => "some video"}
    @update_attrs_contexts %{"picture" => "some updated picture", "text" => "some updated text", "video" => "some updated video"}
    @invalid_attrs_contexts %{"picture" => nil, "text" => nil, "video" => nil}

    def bookmarks_fixture_with_contexts() do
      {:ok, %Contexts{} = context} = Core.create_context(@valid_attrs)
      valid_attrs_bookmark_with_context = @valid_attrs_bookmarks |> Map.put("context_id", context.id)
      {:ok, %Bookmarks{} = bookmarks} = Core.create_bookmarks(valid_attrs_bookmark_with_context, :bookmark_selected_context)

      bookmarks
    end

    test "create_bookmarks/1 with valid data creates a bookmark with context" do
      assert {:ok, %Contexts{} = context} = Core.create_context(@valid_attrs_contexts)
      valid_attrs_bookmark_with_context = @valid_attrs_bookmarks |> Map.put("context_id", context.id)

      assert {:ok, %Bookmarks{} = bookmarks} = Core.create_bookmarks(valid_attrs_bookmark_with_context, :bookmark_selected_context)
      contexts = bookmarks.contexts |> List.first()

      assert bookmarks.name == "some name"
      assert bookmarks.url == "some url"
      assert contexts.picture == context.picture
      assert contexts.text == context.text
      assert contexts.video == context.video
    end

    test "create_bookmarks/1 with invalid data creates a bookmark with context" do
      assert {:ok, %Contexts{} = context} = Core.create_context(@valid_attrs_contexts)
      invalid_attrs_bookmark_with_context = @invalid_attrs_bookmarks |> Map.put("context_id", context.id)

      assert {:error, _} = Core.create_bookmarks(invalid_attrs_bookmark_with_context, :bookmark_selected_context)
    end

    test "create_bookmarks/1 with invalid context" do
      assert {:error, _} = Core.create_context(@invalid_attrs_contexts)
    end

    test "create_bookmarks/1 with valid context attrs" do
      valid_attrs_bookmark_with_context = @valid_attrs_bookmarks |> Map.put("contexts", %{"0" => @valid_attrs_contexts})

      assert {:ok, %Bookmarks{} = bookmarks} = Core.create_bookmarks(valid_attrs_bookmark_with_context, :bookmark_custom_context)
      contexts = bookmarks.contexts |> List.first()

      assert bookmarks.name == "some name"
      assert bookmarks.url == "some url"
      assert contexts.picture == @valid_attrs_contexts["picture"]
      assert contexts.text == @valid_attrs_contexts["text"]
      assert contexts.video == @valid_attrs_contexts["video"]
    end

    test "create_bookmarks/1 with invalid context attrs" do
      valid_attrs_bookmark_with_context = @valid_attrs_bookmarks |> Map.put("contexts", %{"0" => @invalid_attrs_contexts})

      assert {:error, _} = Core.create_bookmarks(valid_attrs_bookmark_with_context, :bookmark_custom_context)
    end

    test "list_bookmark_with_context/0 returns all bookmark with contexts" do
      bookmarks = bookmarks_fixture_with_contexts()
      assert Core.list_bookmark_with_context() == [bookmarks]
    end

    test "get_bookmarks!/1 returns the bookmarks with given id" do
      bookmarks = bookmarks_fixture_with_contexts()
      assert Core.get_bookmarks_with_context!(bookmarks.id) == bookmarks
    end

    test "update_bookmarks/2 with valid data updates the bookmarks" do
      bookmarks = bookmarks_fixture_with_contexts()
      assert {:ok, %Bookmarks{} = updated_bookmarks} = Core.update_bookmarks(bookmarks, @update_attrs_bookmarks)

      assert updated_bookmarks.name == @update_attrs_bookmarks["name"]
      assert updated_bookmarks.url == @update_attrs_bookmarks["url"]
    end

    test "update_bookmarks/2 with valid data updates the bookmarks and select new context" do
      bookmarks = bookmarks_fixture_with_contexts()
      {:ok, contexts_2} = Core.create_context(@update_attrs_contexts)

      valid_update_attrs_bookmarks = @update_attrs_bookmarks |> Map.put("context_id", contexts_2.id)
      assert {:ok, %Bookmarks{} = updated_bookmarks} = Core.update_bookmarks(bookmarks, valid_update_attrs_bookmarks, :edit)

      assert updated_bookmarks.name == @update_attrs_bookmarks["name"]
      assert updated_bookmarks.url == @update_attrs_bookmarks["url"]
      assert contexts_2.picture == @update_attrs_contexts["picture"]
      assert contexts_2.video == @update_attrs_contexts["video"]
      assert contexts_2.text == @update_attrs_contexts["text"]
    end

    test "update_bookmarks/2 with valid data updates the bookmarks and create new context" do
      bookmarks = bookmarks_fixture_with_contexts()
      valid_update_attrs_bookmarks = @update_attrs_bookmarks |> Map.put("contexts", %{"0" => @valid_attrs_contexts}) |> Map.put("context_id", 0)
      assert {:ok, %Bookmarks{} = updated_bookmarks} = Core.update_bookmarks(bookmarks, valid_update_attrs_bookmarks, :edit)

      contexts = updated_bookmarks.contexts |> List.first()

      assert updated_bookmarks.name == @update_attrs_bookmarks["name"]
      assert updated_bookmarks.url == @update_attrs_bookmarks["url"]
      assert contexts.picture == @valid_attrs_contexts["picture"]
      assert contexts.video == @valid_attrs_contexts["video"]
      assert contexts.text == @valid_attrs_contexts["text"]
    end

    test "update_bookmarks/2 with invalid data updates the bookmarks" do
      bookmarks = bookmarks_fixture_with_contexts()
      assert {:error, _} = Core.update_bookmarks(bookmarks, @invalid_attrs_bookmarks)
    end

    test "update_bookmarks/2 with valid data updates the bookmarks and select invalid context" do
      bookmarks = bookmarks_fixture_with_contexts()
      valid_update_attrs_bookmarks = @update_attrs_bookmarks |> Map.put("context_id", 10)
      assert {:error, _} = Core.update_bookmarks(bookmarks, valid_update_attrs_bookmarks, :edit)
    end

    test "update_bookmarks/2 with valid data updates the bookmarks and create invalid context" do
      bookmarks = bookmarks_fixture_with_contexts()
      invalid_update_attrs_bookmarks = @update_attrs_bookmarks |> Map.put("contexts", %{"0" => @invalid_attrs_contexts}) |> Map.put("context_id", 0)
      assert {:error, _} = Core.update_bookmarks(bookmarks, invalid_update_attrs_bookmarks, :edit)
    end

    test "delete_bookmarks/1 deletes the bookmarks without deleting context" do
      bookmarks = bookmarks_fixture_with_contexts()
      assert {:ok, %Bookmarks{} = bookmarks} = Core.delete_bookmarks(bookmarks)
      contexts = bookmarks.contexts |> List.first()
      assert_raise Ecto.NoResultsError, fn -> Core.get_bookmarks!(bookmarks.id) end

      assert contexts.picture == @valid_attrs_contexts["picture"]
      assert contexts.video == @valid_attrs_contexts["video"]
      assert contexts.text == @valid_attrs_contexts["text"]
    end
  end
end
