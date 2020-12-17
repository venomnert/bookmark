defmodule Bookmark.Core.Bookmarks do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookmark.Core.{Contexts, BookmarkContexts}

  schema "bookmarks" do
    field(:name, :string)
    field(:url, :string)

    many_to_many(
      :contexts,
      Contexts,
      join_through: BookmarkContexts,
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(bookmarks, attrs) do
    bookmarks
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
  end

  def changeset_updated_context(bookmarks, context) do
    bookmarks
    |> cast(%{}, [:name, :url])
    |> put_assoc(:contexts, context)
  end
end
