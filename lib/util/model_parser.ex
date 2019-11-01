defmodule ExLemonway.Util.ModelParser do
  @moduledoc """
  Utility helpers for generated model parsers.
  """

  @type model :: %{__struct__: module()}

  @doc """
  Recursively parse model into payload map.
  """
  @spec to_payload(model, [String.t()]) :: {:ok, map()} | {:error, :export_failed}
  def to_payload(%{__struct__: model_module} = model, nested_path \\ []) do
    parser_module = Module.concat([model_module, Parser])

    Enum.reduce_while(Map.from_struct(model), {:ok, %{}}, fn {key, value}, {:ok, payload} ->
      field = apply(parser_module, :key_to_field, [key])
      nested_path = nested_path ++ [field]

      cond do
        is_list(value) ->
          case to_payload_list(value, nested_path) do
            {:ok, subpayload} ->
              {:cont, {:ok, Map.put(payload, field, subpayload)}}

            error ->
              {:halt, error}
          end

        is_map(value) ->
          case value do
            %{__struct__: _submodel_module} = submodel ->
              case to_payload(submodel, nested_path) do
                {:ok, subpayload} ->
                  {:cont, {:ok, Map.put(payload, field, subpayload)}}

                error ->
                  {:halt, error}
              end

            _ ->
              {:cont, {:ok, Map.put(payload, field, value)}}
          end

        true ->
          value = apply(parser_module, :transform_output_value, [key, value])
          {:cont, {:ok, Map.put(payload, field, value)}}
      end
    end)
  end

  # The same as `to_payload` but for lists of models.
  @spec to_payload_list([model], [String.t()]) :: {:ok, [map()]} | {:error, :export_failed}
  defp to_payload_list(submodels, nested_path) when is_list(submodels) and is_list(nested_path) do
    Enum.reduce_while(submodels, {:ok, []}, fn submodel, {:ok, acc} ->
      with %{__struct__: _submodel_module} <- submodel,
           {:ok, subpayload} <- to_payload(submodel, nested_path) do
        {:cont, {:ok, acc ++ [subpayload]}}
      else
        _ ->
          {:halt, {:error, :export_failed}}
      end
    end)
  end

  @doc """
  Recursively parse JSON data into model structs.
  """
  @spec to_struct(map(), module(), [String.t()]) :: {:ok, model} | {:error, :parsing_failed}
  def to_struct(raw_data, model_module, nested_path \\ []) do
    [base_module | _] = Module.split(model_module)
    parser_module = Module.concat([model_module, Parser])

    Enum.reduce_while(raw_data, {:ok, struct(model_module)}, fn {field, value}, {:ok, model} ->
      key = apply(parser_module, :field_to_key, [field])
      nested_path = nested_path ++ [field]

      cond do
        is_nil(key) ->
          {:cont, {:ok, model}}

        is_list(value) and length(value) == 0 ->
          {:cont, {:ok, Map.put(model, key, [])}}

        is_list(value) ->
          submodel_name = apply(parser_module, :submodel_name, [field])
          submodel_module = Module.concat([base_module, submodel_name])

          case to_struct_wrapper(value, submodel_module, submodel_name, nested_path) do
            {:ok, submodels} ->
              {:cont, {:ok, Map.put(model, key, submodels)}}

            error ->
              {:halt, error}
          end

        is_map(value) ->
          submodel_name = apply(parser_module, :submodel_name, [field])
          submodel_module = Module.concat([base_module, submodel_name])

          case to_struct_wrapper(value, submodel_module, submodel_name, nested_path) do
            {:ok, submodule} ->
              {:cont, {:ok, Map.put(model, key, submodule)}}

            error ->
              {:halt, error}
          end

        apply(parser_module, :is_value_valid?, [key, value]) ->
          value = apply(parser_module, :transform_input_value, [key, value])
          {:cont, {:ok, Map.put(model, key, value)}}

        true ->
          {:halt, {:error, :parsing_failed}}
      end
    end)
  end

  # Helper wrapper for recursive parsing.
  @spec to_struct_wrapper(map() | [map()], module(), module() | :not_a_model, [String.t()]) ::
          {:ok, model | [model]} | {:error, :parsing_failed}
  defp to_struct_wrapper(_raw_data, _model_module, :not_a_model, _nested_path),
    do: {:error, :parsing_failed}

  defp to_struct_wrapper(raw_data, model_module, _model_name, nested_path)
       when is_list(raw_data) do
    Enum.reduce_while(raw_data, {:ok, []}, fn raw_model, {:ok, acc} ->
      case to_struct(raw_model, model_module, nested_path) do
        {:ok, submodel} ->
          {:cont, {:ok, acc ++ [submodel]}}

        error ->
          {:halt, error}
      end
    end)
  end

  defp to_struct_wrapper(raw_data, model_module, _model_name, nested_path) do
    to_struct(raw_data, model_module, nested_path)
  end

  @doc """
  Check that value provided for the key is valid.

  Replace default validors with the config like:

      config :ex_lemonway, ExLemonway.SddMandate.Parser,
        validators: %{
          swift: ExLemonway.Validator.Swift
        }
  """
  @spec is_key_value_valid?(module(), atom(), String.t(), any()) :: boolean()
  def is_key_value_valid?(parser_module, key, type, value) do
    validators = parser_module.config(:validators, [])

    case Keyword.get(validators, key) do
      nil ->
        default_validator(type, value)

      custom_validator ->
        custom_validator.is_valid?(value)
    end
  end

  defp default_validator("string", value) when is_binary(value), do: true
  defp default_validator("string", _value), do: false
  defp default_validator("1", value) when is_boolean(value), do: true
  defp default_validator("1", _value), do: false
  defp default_validator(_, nil), do: true

  defp default_validator(model, value) when is_binary(model) do
    model_module = Module.concat(ExLemonway, model)

    if Code.ensure_compiled?(model_module) do
      is_map(value)
    else
      false
    end
  end

  @doc """
  Check that value provided for the struct is adapted to it's expectations.

  Replace default tranformers with the config like:

      config :ex_lemonway, ExLemonway.SddMandate.Parser,
        input_value_transformers: %{
          swift: ExLemonway.Swift.ValueTranformer.Input
        }
  """
  @spec transform_input_value(module(), atom(), String.t(), any()) :: any()
  def transform_input_value(parser_module, key, type, value) do
    transformers = parser_module.config(:input_value_transformers, [])

    case Keyword.get(transformers, key) do
      nil ->
        default_input_transformer(type, value)

      custom_transformer ->
        custom_transformer.transform(value)
    end
  end

  defp default_input_transformer("string", ""), do: nil
  defp default_input_transformer("string", value) when is_binary(value), do: value
  defp default_input_transformer("string", _value), do: nil
  defp default_input_transformer("1", value) when is_boolean(value), do: value
  defp default_input_transformer("1", _value), do: false
  defp default_input_transformer(_type, value), do: value

  @doc """
  Check that value provided for the key is adapted to Lemonway expectations.

  Replace default tranformers with the config like:

      config :ex_lemonway, ExLemonway.SddMandate.Parser,
        output_value_transformers: %{
          swift: ExLemonway.Swift.ValueTranformer.Output
        }
  """
  @spec transform_output_value(module(), atom(), String.t(), any()) :: any()
  def transform_output_value(parser_module, key, type, value) do
    transformers = parser_module.config(:output_value_transformers, [])

    case Keyword.get(transformers, key) do
      nil ->
        default_output_transformer(type, value)

      custom_transformer ->
        custom_transformer.transform(value)
    end
  end

  defp default_output_transformer("string", value) when is_binary(value), do: value
  defp default_output_transformer("string", _value), do: ""
  defp default_output_transformer("1", true), do: "1"
  defp default_output_transformer("1", false), do: "0"
  defp default_output_transformer(_type, value), do: value
end
