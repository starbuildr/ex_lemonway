defmodule <%= inspect specs.module %>ParserTest do
  @moduledoc """
  Test for <%= inspect specs.module %>.Parser.

  It's automatically generated by `mix specs.gen.model <%= specs.name %>`
  Dont' edit this file manually, to make any changes, please update:
  `<%= specs.specs_file %>`
  """
  use ExUnit.Case
  alias <%= inspect specs.module %>
  alias <%= inspect specs.module %>.Parser

  @lemonway_atomic_types Mix.ExLemonway.ModelSpecs.lemonway_atomic_types() |> Enum.map(&String.to_atom/1)

  describe "&to_struct/1" do
    test "should convert from raw data into <%= inspect specs.alias %> model" do
      {%<%= inspect specs.module %>{} = sample, raw_data} = raw_<%= specs.basename %>()
      assert {:ok, struct} = Parser.to_struct(raw_data)
      assert struct === sample
    end

    test "should return parsing error for wrong data" do
      {_sample, raw_data} = raw_<%= specs.basename %>()
      raw_data = Enum.map(raw_data, fn {key, _value} -> {key, nil} end) |> Enum.into(%{})
      assert Parser.to_struct(raw_data) === {:error, :parsing_failed}
    end

    test "should ignore unsupported raw data keys" do
      {sample, raw_data} = raw_<%= specs.basename %>()
      raw_data = Map.put(raw_data, "SMTH_RANDOM", "1")
      assert {:ok, struct} = Parser.to_struct(raw_data)
      assert struct === sample
    end

    test "should put nil on fields missing in raw data" do
      {_sample, raw_data} = raw_<%= specs.basename %>()
      key = Map.keys(raw_data) |> List.last()
      raw_data = Map.delete(raw_data, key)
      assert {:ok, model} = Parser.to_struct(raw_data)
      assert Map.get(model, key) |> is_nil()
    end
  end

  describe "&to_payload/1" do
    test "should convert <%= inspect specs.alias %> model to payload data" do
      {%<%= inspect specs.module %>{} = sample, raw_data} = raw_<%= specs.basename %>()
      assert {:ok, payload} = Parser.to_payload(sample)
      assert payload === raw_data
    end

    test "should put empty values model fields with nil" do
      {sample, raw_data} = raw_<%= specs.basename %>()
      field = Map.keys(raw_data) |> Enum.find(nil, & Parser.field_type(&1) in @lemonway_atomic_types)
      key = Parser.field_to_key(field)
      sample = Map.put(sample, key, nil)
      assert {:ok, payload} = Parser.to_payload(sample)
      assert Map.get(payload, field) === ""
    end
  end

  defp raw_<%= specs.basename %> do
    <% lp = "\n        " %>
    <% raw_fields = for {field, "string"} <- specs.specs_fields do
      ~s("#{field}") <> " => " <> ~s("#{field}")
    end %>
    <% raw_fields = for {field, "1"} <- specs.specs_fields do
      ~s("#{field}") <> " => true"
    end |> Kernel.++(raw_fields) %>
    <% raw_fields = for {field, [_subtype]} <- specs.specs_fields do
      ~s("#{field}") <> " => []"
    end |> Kernel.++(raw_fields) %>
    <% raw_fields = for {field, subtype} when is_binary(subtype) <- specs.specs_fields do
      unless subtype in specs.lemonway_atomic_types do
        ~s("#{field}") <> " => nil"
      end
    end |> Kernel.++(raw_fields) %>
    <% raw_fields = Enum.filter(raw_fields, & &1 !== nil) %>
    raw_data =
      %{<%= lp <> Enum.join(raw_fields, ",#{lp}") %>
      }

    <% fields = for {field, "string"} <- specs.specs_fields do
      Macro.underscore(field) <> ": " <> ~s("#{field}")
    end %>
    <% fields = for {field, "1"} <- specs.specs_fields do
      Macro.underscore(field) <> ": true"
    end |> Kernel.++(fields) %>
    <% fields = for {field, [_subtype]} <- specs.specs_fields do
      Macro.underscore(field) <> ": []"
    end |> Kernel.++(fields) %>
    <% fields = for {field, subtype} when is_binary(subtype) <- specs.specs_fields do
      unless subtype in specs.lemonway_atomic_types do
        Macro.underscore(field) <> ": nil"
      end
    end |> Kernel.++(fields) %>
    <% fields = Enum.filter(fields, & &1 !== nil) %>
    model =
      %<%= specs.name %>{<%= lp <> Enum.join(fields, ",#{lp}") %>
      }

    {model, raw_data}
  end
end
