defmodule Bookmark.Core.Contexts do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookmark.Core.{Bookmarks, BookmarkContexts}

  schema "contexts" do
    field :media, {:array, :string}, default: []
    field :title, :string
    field :text, :string
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
    |> cast(attrs, [:text, :title, :media])
    |> validate_required([:title])
  end
end
