defmodule Bookmark.Core.Bookmarks do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmark" do
    field :name, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(bookmarks, attrs) do
    bookmarks
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
  end
end
