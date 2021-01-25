defmodule Bookmark.Repo.Migrations.CreateContexts do
  use Ecto.Migration

  def change do
    create table(:contexts) do
      add :title, :string
      add :text, :text
      add :media, {:array, :string}, null: false, default: []

      timestamps()
    end

  end
end
