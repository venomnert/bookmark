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

  @doc false
  def changeset(bookmarks, attrs, :empty_context) do
    bookmarks
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
    |> put_assoc(:contexts, [%Contexts{}])  # TODO ensure to accomodate for many context for bookmarks
  end

  @doc false
  def changeset(bookmarks, attrs, :filled_context) do
    # TODO refactor to use ecto function

    # contexts = attrs |> get_in(["contexts", "0"])
    # contexts = %{
    #   "id" => 5,
    #   "picture" => "/hom/img",
    #   "text" => "Context 23",
    #   "video" => "/hom/vid"
    # }

    # attrs = attrs |> Map.put("contexts", [contexts])

    bookmarks
    |> cast(attrs, [:name, :url])
    |> cast_assoc(:contexts, with: &Contexts.changeset/2)
    |> IO.inspect(label: "CONTEXT FINAL")
  end

  def changeset_updated_context(bookmarks, context) do
    bookmarks
    |> cast(%{}, [:name, :url])
    |> put_assoc(:contexts, context)
  end
end
