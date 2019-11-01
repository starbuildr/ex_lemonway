defmodule ExLemonway.Factory.Helpers do
  @moduledoc """
  Helpers for field generators.
  """

  @id_fields ["id", "ID", "Id"]

  @doc """
  Sequince of unique prefixed strings in scope of model
  """
  @spec str_seq(String.t(), any()) :: String.t()
  def str_seq(field, preserve_counter)
      when field in @id_fields and is_integer(preserve_counter) do
    "#{preserve_counter}"
  end

  def str_seq(field, preserve_counter) when is_integer(preserve_counter) do
    nice_field = String.replace(field, "_", "") |> String.capitalize()
    ~s(#{nice_field}#{preserve_counter})
  end

  def str_seq(field, namespace) do
    id = id(namespace)
    str_seq(field, id)
  end

  @doc """
  Sequincial unique id in scope of model.

  Start a new counter if there is none for a namespace.
  """
  @spec id(any()) :: integer()
  def id(namespace) do
    counters_ref =
      with nil <- :persistent_term.get(namespace, nil) do
        counters_ref = :counters.new(1, [])
        :persistent_term.put(namespace, counters_ref)
        counters_ref
      end

    :counters.add(counters_ref, 1, 1)
    :counters.get(counters_ref, 1)
  end

  @doc """
  Get all factory modules form external folder.
  """
  @spec get_factories(String.t()) :: [Module.t()]
  def get_factories(folder) do
    Enum.reduce(File.ls!(folder), [], fn filename, factories ->
      if String.ends_with?(filename, "_factory.ex") do
        [basename | _] = Path.basename(filename) |> String.split(".ex")
        factory = Macro.camelize(basename)
        [{filename, Module.concat(ExLemonway, factory)} | factories]
      else
        factories
      end
    end)
  end

  @doc """
  Helpers to generate specific value for specific types
  """
  @spec gen_value(String.t(), String.t(), String.t() | integer()) :: String.t() | nil
  def gen_value(_, "client_first_name", _namespace), do: "Mark"
  def gen_value(_, "client_last_name", _namespace), do: "Antoniy"
  def gen_value("string", field, namespace), do: str_seq(field, namespace)
  def gen_value("1", _field, _namespace), do: "1"
  def gen_value("ip", _field, _namespace), do: "127.0.0.1"
  def gen_value("email", field, namespace), do: str_seq(field, namespace) <> "@mail.com"
  def gen_value("country", _field, _namespace), do: "NOR"

  def gen_value("phone_number", _field, _namespace),
    do: ~s[#{Enum.random(33_111_111_111..33_999_999_999)}]

  def gen_value(_, _, _), do: nil

  @doc """
  Automatically use all factory files for each defined model.
  """
  defmacro __using__(external_resource) do
    for {filename, factory} <- get_factories(external_resource) do
      quote do
        import ExLemonway.Factory.Helpers
        @external_resource unquote(filename)
        use unquote(factory)
      end
    end
  end
end
