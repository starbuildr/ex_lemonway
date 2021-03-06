defmodule ExLemonway.WalletLimit.Parser do
  @moduledoc """
  Parser to map raw response into WalletLimit model struct.

  It's automatically generated by `mix specs.gen.model WalletLimit`
  Dont' edit this file manually, to make any changes, please update:
  `specs/directkit/model/wallet_limit.json`
  """

  alias ExLemonway.WalletLimit
  alias ExLemonway.Util.ModelParser

  @doc """
  Convert map with string based keys, to a fixed model struct.
  """
  @spec to_struct(map()) :: {:ok, WalletLimit.t()} | {:error, :parsing_failed}
  def to_struct(raw_data) when is_map(raw_data) do
    ModelParser.to_struct(raw_data, ExLemonway.WalletLimit)
  end

  @doc """
  Convert map with string based keys, to a fixed model struct.
  """
  @spec to_payload(WalletLimit.t()) :: {:ok, map()} | {:error, :export_failed}
  def to_payload(%WalletLimit{} = model) do
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
  def field_type("AMOUNTMONEYINALLOWED"), do: :string
  def field_type("TOTALMONEYINALLOWED"), do: :string

  @doc """
  Convert raw string key into struct key atom.
  """
  @spec field_to_key(String.t()) :: atom() | nil
  def field_to_key("AMOUNTMONEYINALLOWED"), do: :amountmoneyinallowed
  def field_to_key("TOTALMONEYINALLOWED"), do: :totalmoneyinallowed
  def field_to_key(_), do: nil

  @doc """
  Convert atomic key to original string key.
  """
  @spec key_to_field(atom()) :: String.t()
  def key_to_field(:amountmoneyinallowed), do: "AMOUNTMONEYINALLOWED"
  def key_to_field(:totalmoneyinallowed), do: "TOTALMONEYINALLOWED"

  @doc """
  Convert raw string key into struct key atom.
  """
  @spec is_value_valid?(atom(), any()) :: boolean()
  def is_value_valid?(:amountmoneyinallowed, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :amountmoneyinallowed, "string", value)

  def is_value_valid?(:totalmoneyinallowed, value),
    do: ModelParser.is_key_value_valid?(__MODULE__, :totalmoneyinallowed, "string", value)

  @doc """
  Convert Lemonway value to struct expectations.
  """
  @spec transform_input_value(atom(), any()) :: any()
  def transform_input_value(:amountmoneyinallowed, value),
    do: ModelParser.transform_input_value(__MODULE__, :amountmoneyinallowed, "string", value)

  def transform_input_value(:totalmoneyinallowed, value),
    do: ModelParser.transform_input_value(__MODULE__, :totalmoneyinallowed, "string", value)

  @doc """
  Convert model value to a payload format.
  """
  @spec transform_output_value(atom(), any()) :: any()
  def transform_output_value(:amountmoneyinallowed, value),
    do: ModelParser.transform_output_value(__MODULE__, :amountmoneyinallowed, "string", value)

  def transform_output_value(:totalmoneyinallowed, value),
    do: ModelParser.transform_output_value(__MODULE__, :totalmoneyinallowed, "string", value)

  @doc """
  Read parser's custom config.
  """
  @spec config(atom(), any()) :: any()
  def config(key, default \\ nil) do
    Application.get_env(:ex_lemonway, __MODULE__, [])
    |> Keyword.get(key, default)
  end
end
