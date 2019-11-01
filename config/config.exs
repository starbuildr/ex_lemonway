use Mix.Config

config :exvcr,
  vcr_cassette_library_dir: "test/support/fixture/vcr_cassettes",
  custom_cassette_library_dir: "test/support/fixture/custom_cassettes"

config :ex_lemonway,
  api_url:
    System.get_env(
      "LEMONWAY_API_URL",
      "https://sandbox-api.lemonway.fr/mb/[ORG_SLUG]/dev/directkitjson2/service.asmx"
    ),
  namespace: ExLemonway,
  http_client: ExLemonway.Util.HttpClient.HTTPoison,
  wl_login: System.get_env("LEMONWAY_LOGIN", ""),
  wl_pass: System.get_env("LEMONWAY_PASSWORD", ""),
  language: "en",
  version: "10.0"

if File.exists?("config/config.secret.exs") do
  import_config "config.secret.exs"
end
