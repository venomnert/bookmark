defmodule Bookmark.Core.BookmarkContexts do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookmark.Core.{Bookmarks, Contexts}

  @already_exists "ALREADY_EXISTS"
  @primary_key false
  @required_fields ~w(bookmark_id contexts_id)a

  schema "bookmark_context" do
    belongs_to(:bookmarks, Bookmarks, primary_key: true)
    belongs_to(:contexts, Contexts, primary_key: true)

    timestamps()
  end

  @doc false
  def changeset(bookmark_context, params \\ %{}) do
    bookmark_context
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:contexts_id)
    |> foreign_key_constraint(:bookmarks_id)
    |> unique_constraint([:bookmarks, :contexts],
      name: :bookmark_id_contexts_id_unique_index,
      message: @already_exists
    )
  end
end
