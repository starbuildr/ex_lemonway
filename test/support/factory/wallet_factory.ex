defmodule ExLemonway.WalletFactory do
  @moduledoc """
  Factory for Wallet.

  It's automatically generated by `mix specs.gen.model Wallet`
  Dont' edit this file manually, to make any changes, please update:
  `specs/directkit/model/wallet.json`
  """

  alias ExLemonway.Wallet

  defmacro __using__(_opts) do
    quote do
      def wallet_factory(params \\ %{}) do
        id = id(ExLemonway.WalletFactory)

        %Wallet{
          bal: gen_value("string", "BAL", id),
          blocked: gen_value("1", "BLOCKED", id),
          birth_city: gen_value("string", "BirthCity", id),
          birth_country: gen_value("string", "BirthCountry", id),
          birth_date: gen_value("string", "BirthDate", id),
          city: gen_value("string", "City", id),
          client_title: gen_value("string", "ClientTitle", id),
          company_description: gen_value("string", "CompanyDescription", id),
          company_identification_number: gen_value("string", "CompanyIdentificationNumber", id),
          company_name: gen_value("string", "CompanyName", id),
          company_website: gen_value("string", "CompanyWebsite", id),
          country: gen_value("string", "Country", id),
          email: gen_value("string", "EMAIL", id),
          first_name: gen_value("string", "FirstName", id),
          id: gen_value("string", "ID", id),
          is_company: gen_value("string", "IsCompany", id),
          is_one_time_customer: gen_value("string", "IsOneTimeCustomer", id),
          is_tech_wallet: gen_value("string", "IsTechWallet", id),
          limits: ExLemonway.Factory.build(:wallet_limit),
          lwid: gen_value("string", "LWID", id),
          last_name: gen_value("string", "LastName", id),
          mobile_number: gen_value("string", "MobileNumber", id),
          name: gen_value("string", "NAME", id),
          nationality: gen_value("string", "Nationality", id),
          phone_number: gen_value("string", "PhoneNumber", id),
          post_code: gen_value("string", "PostCode", id),
          status: gen_value("string", "STATUS", id),
          street: gen_value("string", "Street", id),
          cards: [],
          docs: [],
          ibans: [],
          sddmandates: []
        }
        |> Map.merge(params)
      end
    end
  end
end
