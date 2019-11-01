defmodule ExLemonway.WalletParserTest do
  @moduledoc """
  Test for ExLemonway.Wallet.Parser.

  It's automatically generated by `mix specs.gen.model Wallet`
  Dont' edit this file manually, to make any changes, please update:
  `specs/directkit/model/wallet.json`
  """
  use ExUnit.Case
  alias ExLemonway.Wallet
  alias ExLemonway.Wallet.Parser

  @lemonway_atomic_types Mix.ExLemonway.ModelSpecs.lemonway_atomic_types()
                         |> Enum.map(&String.to_atom/1)

  describe "&to_struct/1" do
    test "should convert from raw data into Wallet model" do
      {%ExLemonway.Wallet{} = sample, raw_data} = raw_wallet()
      assert {:ok, struct} = Parser.to_struct(raw_data)
      assert struct === sample
    end

    test "should return parsing error for wrong data" do
      {_sample, raw_data} = raw_wallet()
      raw_data = Enum.map(raw_data, fn {key, _value} -> {key, nil} end) |> Enum.into(%{})
      assert Parser.to_struct(raw_data) === {:error, :parsing_failed}
    end

    test "should ignore unsupported raw data keys" do
      {sample, raw_data} = raw_wallet()
      raw_data = Map.put(raw_data, "SMTH_RANDOM", "1")
      assert {:ok, struct} = Parser.to_struct(raw_data)
      assert struct === sample
    end

    test "should put nil on fields missing in raw data" do
      {_sample, raw_data} = raw_wallet()
      key = Map.keys(raw_data) |> List.last()
      raw_data = Map.delete(raw_data, key)
      assert {:ok, model} = Parser.to_struct(raw_data)
      assert Map.get(model, key) |> is_nil()
    end
  end

  describe "&to_payload/1" do
    test "should convert Wallet model to payload data" do
      {%ExLemonway.Wallet{} = sample, raw_data} = raw_wallet()
      assert {:ok, payload} = Parser.to_payload(sample)
      assert payload === raw_data
    end

    test "should put empty values model fields with nil" do
      {sample, raw_data} = raw_wallet()

      field =
        Map.keys(raw_data) |> Enum.find(nil, &(Parser.field_type(&1) in @lemonway_atomic_types))

      key = Parser.field_to_key(field)
      sample = Map.put(sample, key, nil)
      assert {:ok, payload} = Parser.to_payload(sample)
      assert Map.get(payload, field) === ""
    end
  end

  defp raw_wallet do
    raw_data = %{
      "LIMITS" => nil,
      "CARDS" => [],
      "DOCS" => [],
      "IBANS" => [],
      "SDDMANDATES" => [],
      "BLOCKED" => true,
      "BAL" => "BAL",
      "BirthCity" => "BirthCity",
      "BirthCountry" => "BirthCountry",
      "BirthDate" => "BirthDate",
      "City" => "City",
      "ClientTitle" => "ClientTitle",
      "CompanyDescription" => "CompanyDescription",
      "CompanyIdentificationNumber" => "CompanyIdentificationNumber",
      "CompanyName" => "CompanyName",
      "CompanyWebsite" => "CompanyWebsite",
      "Country" => "Country",
      "EMAIL" => "EMAIL",
      "FirstName" => "FirstName",
      "ID" => "ID",
      "IsCompany" => "IsCompany",
      "IsOneTimeCustomer" => "IsOneTimeCustomer",
      "IsTechWallet" => "IsTechWallet",
      "LWID" => "LWID",
      "LastName" => "LastName",
      "MobileNumber" => "MobileNumber",
      "NAME" => "NAME",
      "Nationality" => "Nationality",
      "PhoneNumber" => "PhoneNumber",
      "PostCode" => "PostCode",
      "STATUS" => "STATUS",
      "Street" => "Street"
    }

    model = %Wallet{
      limits: nil,
      cards: [],
      docs: [],
      ibans: [],
      sddmandates: [],
      blocked: true,
      bal: "BAL",
      birth_city: "BirthCity",
      birth_country: "BirthCountry",
      birth_date: "BirthDate",
      city: "City",
      client_title: "ClientTitle",
      company_description: "CompanyDescription",
      company_identification_number: "CompanyIdentificationNumber",
      company_name: "CompanyName",
      company_website: "CompanyWebsite",
      country: "Country",
      email: "EMAIL",
      first_name: "FirstName",
      id: "ID",
      is_company: "IsCompany",
      is_one_time_customer: "IsOneTimeCustomer",
      is_tech_wallet: "IsTechWallet",
      lwid: "LWID",
      last_name: "LastName",
      mobile_number: "MobileNumber",
      name: "NAME",
      nationality: "Nationality",
      phone_number: "PhoneNumber",
      post_code: "PostCode",
      status: "STATUS",
      street: "Street"
    }

    {model, raw_data}
  end
end
