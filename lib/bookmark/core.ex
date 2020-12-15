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

  alias Bookmark.Core.Context

  @doc """
  Returns the list of contexts.

  ## Examples

      iex> list_contexts()
      [%Context{}, ...]

  """
  def list_contexts do
    Repo.all(Context)
  end

  @doc """
  Gets a single context.

  Raises `Ecto.NoResultsError` if the Context does not exist.

  ## Examples

      iex> get_context!(123)
      %Context{}

      iex> get_context!(456)
      ** (Ecto.NoResultsError)

  """
  def get_context!(id), do: Repo.get!(Context, id)

  @doc """
  Creates a context.

  ## Examples

      iex> create_context(%{field: value})
      {:ok, %Context{}}

      iex> create_context(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_context(attrs \\ %{}) do
    %Context{}
    |> Context.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a context.

  ## Examples

      iex> update_context(context, %{field: new_value})
      {:ok, %Context{}}

      iex> update_context(context, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_context(%Context{} = context, attrs) do
    context
    |> Context.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a context.

  ## Examples

      iex> delete_context(context)
      {:ok, %Context{}}

      iex> delete_context(context)
      {:error, %Ecto.Changeset{}}

  """
  def delete_context(%Context{} = context) do
    Repo.delete(context)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking context changes.

  ## Examples

      iex> change_context(context)
      %Ecto.Changeset{data: %Context{}}

  """
  def change_context(%Context{} = context, attrs \\ %{}) do
    Context.changeset(context, attrs)
  end
end
