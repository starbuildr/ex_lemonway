defmodule ExLemonway.CardParserTest do
  @moduledoc """
  Test for ExLemonway.Card.Parser.

  It's automatically generated by `mix specs.gen.model Card`
  Dont' edit this file manually, to make any changes, please update:
  `specs/directkit/model/card.json`
  """
  use ExUnit.Case
  alias ExLemonway.Card
  alias ExLemonway.Card.Parser

  @lemonway_atomic_types Mix.ExLemonway.ModelSpecs.lemonway_atomic_types()
                         |> Enum.map(&String.to_atom/1)

  describe "&to_struct/1" do
    test "should convert from raw data into Card model" do
      {%ExLemonway.Card{} = sample, raw_data} = raw_card()
      assert {:ok, struct} = Parser.to_struct(raw_data)
      assert struct === sample
    end

    test "should return parsing error for wrong data" do
      {_sample, raw_data} = raw_card()
      raw_data = Enum.map(raw_data, fn {key, _value} -> {key, nil} end) |> Enum.into(%{})
      assert Parser.to_struct(raw_data) === {:error, :parsing_failed}
    end

    test "should ignore unsupported raw data keys" do
      {sample, raw_data} = raw_card()
      raw_data = Map.put(raw_data, "SMTH_RANDOM", "1")
      assert {:ok, struct} = Parser.to_struct(raw_data)
      assert struct === sample
    end

    test "should put nil on fields missing in raw data" do
      {_sample, raw_data} = raw_card()
      key = Map.keys(raw_data) |> List.last()
      raw_data = Map.delete(raw_data, key)
      assert {:ok, model} = Parser.to_struct(raw_data)
      assert Map.get(model, key) |> is_nil()
    end
  end

  describe "&to_payload/1" do
    test "should convert Card model to payload data" do
      {%ExLemonway.Card{} = sample, raw_data} = raw_card()
      assert {:ok, payload} = Parser.to_payload(sample)
      assert payload === raw_data
    end

    test "should put empty values model fields with nil" do
      {sample, raw_data} = raw_card()

      field =
        Map.keys(raw_data) |> Enum.find(nil, &(Parser.field_type(&1) in @lemonway_atomic_types))

      key = Parser.field_to_key(field)
      sample = Map.put(sample, key, nil)
      assert {:ok, payload} = Parser.to_payload(sample)
      assert Map.get(payload, field) === ""
    end
  end

  defp raw_card do
    raw_data = %{
      "EXTRA" => nil,
      "ID" => "ID"
    }

    model = %Card{
      extra: nil,
      id: "ID"
    }

    {model, raw_data}
  end
end
