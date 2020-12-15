defmodule Bookmark.Repo.Migrations.CreateContexts do
  use Ecto.Migration

  def change do
    create table(:contexts) do
      add :text, :string
      add :video, :string
      add :picture, :string

      timestamps()
    end

  end
end
