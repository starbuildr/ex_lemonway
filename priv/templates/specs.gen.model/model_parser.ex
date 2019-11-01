defmodule <%= inspect specs.base_module %>.<%= inspect specs.alias %>.Parser do
  @moduledoc """
  Parser to map raw response into <%= specs.name %> model struct.

  It's automatically generated by `mix specs.gen.model <%= specs.name %>`
  Dont' edit this file manually, to make any changes, please update:
  `<%= specs.specs_file %>`
  """

  alias <%= inspect specs.module %>
  alias ExLemonway.Util.ModelParser

  @doc """
  Convert map with string based keys, to a fixed model struct.
  """
  @spec to_struct(map()) :: {:ok, <%= inspect specs.alias %>.t()} | {:error, :parsing_failed}
  def to_struct(raw_data) when is_map(raw_data) do
    ModelParser.to_struct(raw_data, <%= inspect specs.module %>)
  end

  @doc """
  Convert map with string based keys, to a fixed model struct.
  """
  @spec to_payload(<%= inspect specs.alias %>.t()) :: {:ok, map()} | {:error, :export_failed}
  def to_payload(%<%= inspect specs.alias %>{} = model) do
    ModelParser.to_payload(model)
  end

  @doc """
  Infer model alias by raw string key.
  """
  @spec submodel_name(String.t()) :: atom()
  <%= for {field, [subtype]} <- specs.specs_fields do %>
  def submodel_name("<%= field %>"), do: <%= subtype %>
  <% end %>
  <%= for {field, subtype} when is_binary(subtype) <- specs.specs_fields do %>
  <%= unless subtype in specs.lemonway_atomic_types do %>
  def submodel_name("<%= field %>"), do: <%= subtype %>
  <% end %>
  <% end %>
  def submodel_name(_), do: :not_a_model

  @doc """
  Get type for specific field.
  """
  @spec field_type(String.t()) :: atom()
  <%= for {field, type} when is_binary(type) or is_list(type) <- specs.specs_fields do %>
  <%= cond do %>
  <% type === "1" -> %>
  def field_type("<%= field %>"), do: :boolean
  <% type in specs.lemonway_atomic_types -> %>
  def field_type("<%= field %>"), do: :<%= Macro.underscore(type) %>
  <% true -> %>
  def field_type("<%= field %>"), do: submodel_name("<%= field %>")
  <% end %>
  <% end %>

  @doc """
  Convert raw string key into struct key atom.
  """
  @spec field_to_key(String.t()) :: atom() | nil
  <%= for {field, type} when is_binary(type) or is_list(type) <- specs.specs_fields do %>
  def field_to_key("<%= field %>"), do: :<%= Macro.underscore(field) %>
  <% end %>
  def field_to_key(_), do: nil

  @doc """
  Convert atomic key to original string key.
  """
  @spec key_to_field(atom()) :: String.t()
  <%= for {field, type} when is_binary(type) or is_list(type) <- specs.specs_fields do %>
  def key_to_field(:<%= Macro.underscore(field) %>), do: "<%= field %>"
  <% end %>

  @doc """
  Convert raw string key into struct key atom.
  """
  @spec is_value_valid?(atom(), any()) :: boolean()
  <%= for {field, type} when is_binary(type) <- specs.specs_fields do %>
  <% key = Macro.underscore(field) %>
  def is_value_valid?(:<%= key %>, value), do: ModelParser.is_key_value_valid?(__MODULE__, :<%= key %>, "<%= type %>", value)
  <% end %>

  @doc """
  Convert Lemonway value to struct expectations.
  """
  @spec transform_input_value(atom(), any()) :: any()
  <%= for {field, type} when is_binary(type) <- specs.specs_fields do %>
  <% key = Macro.underscore(field) %>
  def transform_input_value(:<%= key %>, value), do: ModelParser.transform_input_value(__MODULE__, :<%= key %>, "<%= type %>", value)
  <% end %>

  @doc """
  Convert model value to a payload format.
  """
  @spec transform_output_value(atom(), any()) :: any()
  <%= for {field, type} when is_binary(type) <- specs.specs_fields do %>
  <% key = Macro.underscore(field) %>
  def transform_output_value(:<%= key %>, value), do: ModelParser.transform_output_value(__MODULE__, :<%= key %>, "<%= type %>", value)
  <% end %>

  @doc """
  Read parser's custom config.
  """
  @spec config(atom(), any()) :: any()
  def config(key, default \\ nil) do
    Application.get_env(:<%= specs.opt_app %>, __MODULE__, [])
    |> Keyword.get(key, default)
  end
end
