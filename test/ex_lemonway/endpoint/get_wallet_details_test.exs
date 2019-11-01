defmodule ExLemonway.Endpoint.GetWalletDetailsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias ExLemonway.Endpoint.GetWalletDetails

  setup do
    parent_dir = Application.get_env(:exvcr, :vcr_cassette_library_dir)
    ExVCR.Config.cassette_library_dir("#{parent_dir}/lemonway")
    :ok
  end

  describe "&request/1" do
    test "should perform HTTP requests for valid payload" do
      use_cassette "get_wallet_details" do
        payload = %GetWalletDetails.Request{
          email: "clientmail1581254452@mail.com",
          wallet: "Wallet1581254452"
        }

        assert {:ok, %GetWalletDetails.Response{} = _response} = GetWalletDetails.request(payload)
      end
    end
  end
end
