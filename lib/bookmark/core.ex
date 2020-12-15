defmodule Bookmark.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false
  alias Bookmark.Repo

  alias Bookmark.Core.Bookmarks

  @doc """
  Returns the list of bookmark.

  ## Examples

      iex> list_bookmark()
      [%Bookmarks{}, ...]

  """
  def list_bookmark do
    Repo.all(Bookmarks)
  end

  @doc """
  Gets a single bookmarks.

  Raises `Ecto.NoResultsError` if the Bookmarks does not exist.

  ## Examples

      iex> get_bookmarks!(123)
      %Bookmarks{}

      iex> get_bookmarks!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bookmarks!(id), do: Repo.get!(Bookmarks, id)

  @doc """
  Creates a bookmarks.

  ## Examples

      iex> create_bookmarks(%{field: value})
      {:ok, %Bookmarks{}}

      iex> create_bookmarks(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bookmarks(attrs \\ %{}) do
    %Bookmarks{}
    |> Bookmarks.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bookmarks.

  ## Examples

      iex> update_bookmarks(bookmarks, %{field: new_value})
      {:ok, %Bookmarks{}}

      iex> update_bookmarks(bookmarks, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bookmarks(%Bookmarks{} = bookmarks, attrs) do
    bookmarks
    |> Bookmarks.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bookmarks.

  ## Examples

      iex> delete_bookmarks(bookmarks)
      {:ok, %Bookmarks{}}

      iex> delete_bookmarks(bookmarks)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bookmarks(%Bookmarks{} = bookmarks) do
    Repo.delete(bookmarks)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bookmarks changes.

  ## Examples

      iex> change_bookmarks(bookmarks)
      %Ecto.Changeset{data: %Bookmarks{}}

  """
  def change_bookmarks(%Bookmarks{} = bookmarks, attrs \\ %{}) do
    Bookmarks.changeset(bookmarks, attrs)
  end
end
