defmodule Bookmark.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false
  alias Bookmark.Repo
  alias Bookmark.Core.{Bookmarks, Contexts}

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
  Returns the list of bookmark.

  ## Examples

      iex> list_bookmark()
      [%Bookmarks{}, ...]

  """
  def list_bookmark_with_context do
    Bookmarks
    |> Repo.all()
    |> Repo.preload(:contexts)
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
  Gets a single bookmarks with preloaded contexts.

  Raises `Ecto.NoResultsError` if the Bookmarks does not exist.

  ## Examples

      iex> get_bookmarks!(123)
      %Bookmarks{}

      iex> get_bookmarks!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bookmarks_with_context!(id) do
    Bookmarks
    |> Repo.get!(id)
    |> Repo.preload(:contexts)
  end

  # TODO doc
  def empty_bookmark_with_context() do
    %Bookmarks{}
    |> Repo.preload(:contexts)
    |> Map.put(:contexts, [%Contexts{}])
  end

  # TODO doc
  def create_bookmarks(%{"context_id" => context_id} = attrs, :bookmark_selected_context) do
    %Bookmarks{}
    |> Bookmarks.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, bookmark} -> upsert_bookmark_context(bookmark, [context_id])
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Creates a bookmarks.

  ## Examples

      iex> create_bookmarks(%{field: value})
      {:ok, %Bookmarks{}}

      iex> create_bookmarks(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bookmarks(attrs, :bookmark_custom_context) do
    %Bookmarks{}
    |> Bookmarks.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:contexts, with: &__MODULE__.change_context/2)
    |> Repo.insert()
    |> case do
      {:ok, bookmark} -> {:ok, bookmark}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Creates a bookmarks.

  ## Examples

      iex> create_bookmarks(%{field: value})
      {:ok, %Bookmarks{}}

      iex> create_bookmarks(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bookmarks(attrs, :bookmark) do
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
  Updates a bookmarks.

  ## Examples

      iex> update_bookmarks(bookmarks, %{field: new_value})
      {:ok, %Bookmarks{}}

      iex> update_bookmarks(bookmarks, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bookmarks(%Bookmarks{} = bookmarks, %{"context_id" => context_id} = attrs, :edit) do
    context_id
    |> case do
      nil ->
        bookmarks
        |> __MODULE__.change_bookmarks(attrs, :filled_context)
        |> Repo.update()

      0 ->
        contexts_changeset = change_context(%Contexts{}, get_in(attrs, ["contexts", "0"]))

        contexts_changeset.valid?
        |> case do
          true ->
            contexts = Map.get(contexts_changeset, :changes)

            bookmarks
            |> Repo.preload(:contexts)
            |> Bookmarks.changeset(attrs)
            |> Ecto.Changeset.put_assoc(:contexts, [contexts])
            |> Repo.update()

          false ->
            {:error, contexts_changeset}
        end

      id when id > 0 ->
        id
        |> get_context()
        |> case do
          nil ->
            {:error, nil}

          contexts ->
            bookmarks
            |> Repo.preload(:contexts)
            |> Bookmarks.changeset(attrs)
            |> Ecto.Changeset.put_assoc(:contexts, [contexts])
            |> Repo.update()
        end
    end
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

  def change_bookmarks(%Bookmarks{} = bookmarks, attrs, :empty_context) do
    Bookmarks.changeset(bookmarks, attrs, :empty_context)
  end

  def change_bookmarks(%Bookmarks{} = bookmarks, attrs, :filled_context) do
    Bookmarks.changeset(bookmarks, attrs, :filled_context)
  end


  def upsert_bookmark_context(%Bookmarks{} = bookmarks, context_ids) when is_list(context_ids) do
    contexts =
      Contexts
      |> where([context], context.id in ^context_ids)
      |> Repo.all()

    with {:ok, _struct} <-
           bookmarks
           |> Repo.preload(:contexts)
           |> Bookmarks.changeset_updated_context(contexts)
           |> Repo.update() do
      {:ok, __MODULE__.get_bookmarks_with_context!(bookmarks.id)}
    else
      error -> error
    end
  end

  @doc """
  Returns the list of contexts.

  ## Examples

      iex> list_contexts()
      [%Contexts{}, ...]

  """
  def list_contexts do
    Repo.all(Contexts)
  end

  @doc """
  Gets a single context.

  Raises `Ecto.NoResultsError` if the Contexts does not exist.

  ## Examples

      iex> get_context!(123)
      %Contexts{}

      iex> get_context!(456)
      ** (Ecto.NoResultsError)

  """
  def get_context(id), do: Repo.get(Contexts, id)

  @doc """
  Gets a single context.

  Raises `Ecto.NoResultsError` if the Contexts does not exist.

  ## Examples

      iex> get_context!(123)
      %Contexts{}

      iex> get_context!(456)
      ** (Ecto.NoResultsError)

  """
  def get_context!(id), do: Repo.get!(Contexts, id)

  @doc """
  Creates a context.

  ## Examples

      iex> create_context(%{field: value})
      {:ok, %Contexts{}}

      iex> create_context(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_context(attrs \\ %{}) do
    %Contexts{}
    |> Contexts.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a context.

  ## Examples

      iex> update_context(context, %{field: new_value})
      {:ok, %Contexts{}}

      iex> update_context(context, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_context(%Contexts{} = context, attrs) do
    context
    |> Contexts.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a context.

  ## Examples

      iex> delete_context(context)
      {:ok, %Contexts{}}

      iex> delete_context(context)
      {:error, %Ecto.Changeset{}}

  """
  def delete_context(%Contexts{} = context) do
    Repo.delete(context)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking context changes.

  ## Examples

      iex> change_context(context)
      %Ecto.Changeset{data: %Contexts{}}

  """
  def change_context(%Contexts{} = context, attrs \\ %{}) do
    Contexts.changeset(context, attrs)
  end
end
