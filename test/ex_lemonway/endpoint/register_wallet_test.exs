defmodule ExLemonway.Endpoint.RegisterWalletTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias ExLemonway.Factory.Helpers
  alias ExLemonway.Endpoint.RegisterWallet

  setup do
    parent_dir = Application.get_env(:exvcr, :vcr_cassette_library_dir)
    ExVCR.Config.cassette_library_dir("#{parent_dir}/lemonway")
    :ok
  end

  describe "&request/1" do
    test "should perform HTTP requests for valid payload" do
      use_cassette "register_wallet" do
        id = :os.system_time(:seconds)

        payload = %RegisterWallet.Request{
          birthcity: Helpers.gen_value("string", "birthcity", id),
          birthcountry: Helpers.gen_value("country", "birthcountry", id),
          birthdate: Helpers.gen_value("string", "birthdate", id),
          city: Helpers.gen_value("string", "city", id),
          client_first_name: Helpers.gen_value("string", "client_first_name", id),
          client_last_name: Helpers.gen_value("string", "client_last_name", id),
          client_mail: Helpers.gen_value("email", "client_mail", id),
          client_title: Helpers.gen_value("string", "client_title", id),
          company_description: Helpers.gen_value("string", "company_description", id),
          company_identification_number:
            Helpers.gen_value("string", "company_identification_number", id),
          company_name: Helpers.gen_value("string", "company_name", id),
          company_website: Helpers.gen_value("string", "company_website", id),
          ctry: Helpers.gen_value("country", "ctry", id),
          is_company: Helpers.gen_value("1", "is_company", id),
          is_debtor: Helpers.gen_value("1", "is_debtor", id),
          is_one_time_customer: Helpers.gen_value("1", "is_one_time_customer", id),
          is_tech_wallet: Helpers.gen_value("1", "is_tech_wallet", id),
          mobile_number: Helpers.gen_value("phone_number", "mobile_number", id),
          nationality: Helpers.gen_value("country", "nationality", id),
          payer_or_beneficiary: Helpers.gen_value("1", "payer_or_beneficiary", id),
          phone_number: Helpers.gen_value("phone_number", "phone_number", id),
          post_code: Helpers.gen_value("string", "post_code", id),
          street: Helpers.gen_value("string", "street", id),
          wallet: Helpers.gen_value("string", "wallet", id)
        }

        assert {:ok, %RegisterWallet.Response{} = _response} = RegisterWallet.request(payload)
      end
    end
  end
end
