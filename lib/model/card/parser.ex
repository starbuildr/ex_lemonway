defmodule ExLemonway.Card.Parser do
  @moduledoc """
  Parser to map raw response into Card model struct.

  It's automatically generated by `mix specs.gen.model Card`
  Dont' edit this file manually, to make any changes, please update:
  `specs/directkit/model/card.json`
  """

  alias ExLemonway.Card
  alias ExLemonway.Util.ModelParser

  @doc """
  Convert map with string based keys, to a fixed model struct.
  """
  @spec to_struct(map()) :: {:ok, Card.t()} | {:error, :parsing_failed}
  def to_struct(raw_data) when is_map(raw_data) do
    ModelParser.to_struct(raw_data, ExLemonway.Card)
  end

  @doc """
  Convert map with string based keys, to a fixed model struct.
  """
  @spec to_payload(Card.t()) :: {:ok, map()} | {:error, :export_failed}
  def to_payload(%Card{} = model) do
    ModelParser.to_payload(model)
  end

  @doc """
  Infer model alias by raw string key.
  """
  @spec submodel_name(String.t()) :: atom()
  def submodel_name("EXTRA"), do: CardExtra
  def submodel_name(_), do: :not_a_model

  @doc """
  Get type for specific field.
  """
  @spec field_type(String.t()) :: atom()
  def field_type("EXTRA"), do: submodel_name("EXTRA")
  def field_type("ID"), do: :string

  @doc """
  Convert raw string key into struct key atom.
  """
  @spec field_to_key(String.t()) :: atom() | nil
  def field_to_key("EXTRA"), do: :extra
  def field_to_key("ID"), do: :id
  def field_to_key(_), do: nil

  @doc """
  Convert atomic key to original string key.
  """
  @spec key_to_field(atom()) :: String.t()
  def key_to_field(:extra), do: "EXTRA"
  def key_to_field(:id), do: "ID"

  @doc """
  Convert raw string key into struct key atom.
  """
  @spec is_value_valid?(atom(), any()) :: boolean()
  def is_value_valid?(:extra, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :extra, "CardExtra", value)

  def is_value_valid?(:id, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :id, "string", value)

  @doc """
  Convert Lemonway value to struct expectations.
  """
  @spec transform_input_value(atom(), any()) :: any()
  def transform_input_value(:extra, value),
    do: ModelParser.transform_input_value(__MODULE__, :extra, "CardExtra", value)

  def transform_input_value(:id, value),
    do: ModelParser.transform_input_value(__MODULE__, :id, "string", value)

  @doc """
  Convert model value to a payload format.
  """
  @spec transform_output_value(atom(), any()) :: any()
  def transform_output_value(:extra, value),
    do: ModelParser.transform_output_value(__MODULE__, :extra, "CardExtra", value)

  def transform_output_value(:id, value),
    do: ModelParser.transform_output_value(__MODULE__, :id, "string", value)

  @doc """
  Read parser's custom config.
  """
  @spec config(atom(), any()) :: any()
  def config(key, default \\ nil) do
    Application.get_env(:ex_lemonway, __MODULE__, [])
    |> Keyword.get(key, default)
  end
end
