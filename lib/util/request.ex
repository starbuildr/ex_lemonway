defmodule ExLemonway.Util.Request do
  @moduledoc """
  Utility wrapper for making HTTP requests.

  Delegates to the configured HTTP client module.
  """
  use ExLemonway.Behaviour.HttpClient

  @doc """
  Add default variables to payload.
  """
  @spec enhance_payload(map(), nil | String.t()) :: map()
  def enhance_payload(payload, ip \\ nil) when is_map(payload) do
    Map.merge(payload, %{
      "wlLogin" => Application.get_env(:ex_lemonway, :wl_login),
      "wlPass" => Application.get_env(:ex_lemonway, :wl_pass),
      "language" => Application.get_env(:ex_lemonway, :language),
      "version" => Application.get_env(:ex_lemonway, :version),
      "walletIp" => ip || "127.0.0.1"
    })
  end
end
