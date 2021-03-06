defmodule ExLemonway.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_lemonway,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:elixir_uuid, "~> 1.2"},
      {:httpoison, "~> 1.6"},
      {:exvcr, "~> 0.10", only: :test},
      {:ibrowse, "~> 4.2", only: :test}
    ]
  end
end
