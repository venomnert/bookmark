defmodule Bookmark.Core.Context do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contexts" do
    field :picture, :string
    field :text, :string
    field :video, :string

    timestamps()
  end

  @doc false
  def changeset(context, attrs) do
    context
    |> cast(attrs, [:text, :video, :picture])
    |> validate_required([:text, :video, :picture])
  end
end
