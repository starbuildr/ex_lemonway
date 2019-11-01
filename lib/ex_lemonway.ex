defmodule ExLemonway do
  @moduledoc """
  Documentation for ExLemonway.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExLemonway.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Read application config.
  """
  @spec config(atom(), any()) :: any()
  def config(key, default \\ nil) do
    Application.get_env(:ex_lemonway, key, default)
  end
end
