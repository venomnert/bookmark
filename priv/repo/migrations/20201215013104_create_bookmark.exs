defmodule Bookmark.Repo.Migrations.CreateBookmark do
  use Ecto.Migration

  def change do
    create table(:bookmark) do
      add :name, :string
      add :url, :string

      timestamps()
    end

  end
end
