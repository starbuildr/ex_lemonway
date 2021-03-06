defmodule ExLemonway.CardExtra.Parser do
  @moduledoc """
  Parser to map raw response into CardExtra model struct.

  It's automatically generated by `mix specs.gen.model CardExtra`
  Dont' edit this file manually, to make any changes, please update:
  `specs/directkit/model/card_extra.json`
  """

  alias ExLemonway.CardExtra
  alias ExLemonway.Util.ModelParser

  @doc """
  Convert map with string based keys, to a fixed model struct.
  """
  @spec to_struct(map()) :: {:ok, CardExtra.t()} | {:error, :parsing_failed}
  def to_struct(raw_data) when is_map(raw_data) do
    ModelParser.to_struct(raw_data, ExLemonway.CardExtra)
  end

  @doc """
  Convert map with string based keys, to a fixed model struct.
  """
  @spec to_payload(CardExtra.t()) :: {:ok, map()} | {:error, :export_failed}
  def to_payload(%CardExtra{} = model) do
    ModelParser.to_payload(model)
  end

  @doc """
  Infer model alias by raw string key.
  """
  @spec submodel_name(String.t()) :: atom()
  def submodel_name(_), do: :not_a_model

  @doc """
  Get type for specific field.
  """
  @spec field_type(String.t()) :: atom()
  def field_type("AUTH"), do: :string
  def field_type("CTRY"), do: :string
  def field_type("EXP"), do: :string
  def field_type("IS3DS"), do: :string
  def field_type("NUM"), do: :string
  def field_type("TYP"), do: :string

  @doc """
  Convert raw string key into struct key atom.
  """
  @spec field_to_key(String.t()) :: atom() | nil
  def field_to_key("AUTH"), do: :auth
  def field_to_key("CTRY"), do: :ctry
  def field_to_key("EXP"), do: :exp
  def field_to_key("IS3DS"), do: :i_s3_ds
  def field_to_key("NUM"), do: :num
  def field_to_key("TYP"), do: :typ
  def field_to_key(_), do: nil

  @doc """
  Convert atomic key to original string key.
  """
  @spec key_to_field(atom()) :: String.t()
  def key_to_field(:auth), do: "AUTH"
  def key_to_field(:ctry), do: "CTRY"
  def key_to_field(:exp), do: "EXP"
  def key_to_field(:i_s3_ds), do: "IS3DS"
  def key_to_field(:num), do: "NUM"
  def key_to_field(:typ), do: "TYP"

  @doc """
  Convert raw string key into struct key atom.
  """
  @spec is_value_valid?(atom(), any()) :: boolean()
  def is_value_valid?(:auth, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :auth, "string", value)

  def is_value_valid?(:ctry, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :ctry, "string", value)

  def is_value_valid?(:exp, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :exp, "string", value)

  def is_value_valid?(:i_s3_ds, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :i_s3_ds, "string", value)

  def is_value_valid?(:num, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :num, "string", value)

  def is_value_valid?(:typ, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :typ, "string", value)

  @doc """
  Convert Lemonway value to struct expectations.
  """
  @spec transform_input_value(atom(), any()) :: any()
  def transform_input_value(:auth, value),
    do: ModelParser.transform_input_value(__MODULE__, :auth, "string", value)

  def transform_input_value(:ctry, value),
    do: ModelParser.transform_input_value(__MODULE__, :ctry, "string", value)

  def transform_input_value(:exp, value),
    do: ModelParser.transform_input_value(__MODULE__, :exp, "string", value)

  def transform_input_value(:i_s3_ds, value),
    do: ModelParser.transform_input_value(__MODULE__, :i_s3_ds, "string", value)

  def transform_input_value(:num, value),
    do: ModelParser.transform_input_value(__MODULE__, :num, "string", value)

  def transform_input_value(:typ, value),
    do: ModelParser.transform_input_value(__MODULE__, :typ, "string", value)

  @doc """
  Convert model value to a payload format.
  """
  @spec transform_output_value(atom(), any()) :: any()
  def transform_output_value(:auth, value),
    do: ModelParser.transform_output_value(__MODULE__, :auth, "string", value)

  def transform_output_value(:ctry, value),
    do: ModelParser.transform_output_value(__MODULE__, :ctry, "string", value)

  def transform_output_value(:exp, value),
    do: ModelParser.transform_output_value(__MODULE__, :exp, "string", value)

  def transform_output_value(:i_s3_ds, value),
    do: ModelParser.transform_output_value(__MODULE__, :i_s3_ds, "string", value)

  def transform_output_value(:num, value),
    do: ModelParser.transform_output_value(__MODULE__, :num, "string", value)

  def transform_output_value(:typ, value),
    do: ModelParser.transform_output_value(__MODULE__, :typ, "string", value)

  @doc """
  Read parser's custom config.
  """
  @spec config(atom(), any()) :: any()
  def config(key, default \\ nil) do
    Application.get_env(:ex_lemonway, __MODULE__, [])
    |> Keyword.get(key, default)
  end
end
