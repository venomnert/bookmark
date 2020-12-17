defmodule Bookmark.Repo.Migrations.CreateBookmarkContextable do
  use Ecto.Migration

  def change do
    create table(:bookmark_context, primary_key: false) do
      add(:contexts_id, references(:contexts, on_delete: :delete_all), primary_key: true)
      add(:bookmarks_id, references(:bookmarks, on_delete: :delete_all), primary_key: true)
      timestamps()
    end

    create(index(:bookmark_context, [:contexts_id]))
    create(index(:bookmark_context, [:bookmarks_id]))
  end
end
