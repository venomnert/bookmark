defmodule Bookmark.Core.Contexts do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookmark.Core.{Bookmarks, BookmarkContexts}

  schema "contexts" do
    field :picture, :string
    field :text, :string
    field :video, :string
    many_to_many(
      :bookmark,
      Bookmarks,
      join_through: BookmarkContexts,
      on_replace: :delete
    )
    timestamps()
  end

  @doc false
  def changeset(context, attrs) do
    context
    |> cast(attrs, [:text, :video, :picture])
    |> validate_required([:text, :video, :picture])
  end
end
