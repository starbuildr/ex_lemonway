defmodule Mix.Tasks.Specs.Gen.Model do
  @shortdoc "Generates Elixir models based on specs in specs/directkit/model folder"

  use Mix.Task
  alias Mix.ExLemonway.ModelSpecs

  @supported_models [
    "Card",
    "CardExtra",
    "Wallet",
    "WalletLimit"
  ]

  @impl Mix.Task
  @shortdoc "Generate model file based on JSON specs with related tests"
  @spec run([String.t()]) :: any()
  def run(args) do
    if Enum.find(args, nil, &(&1 === "--all")) do
      args = Enum.filter(args, &(&1 !== "--all"))

      for model <- @supported_models do
        run([model | args])
      end
    else
      specs = ModelSpecs.build(args)
      paths = Mix.ExLemonway.generator_paths()
      bindings = enhance_bindings(specs: specs)

      prompt_for_code_injection(specs)

      specs
      |> copy_new_files(paths, bindings)
    end
  end

  def copy_new_files(%ModelSpecs{} = specs, paths, binding) do
    inject_model(specs, paths, binding)
    inject_test_factory(specs, paths, binding)
    inject_model_parser(specs, paths, binding)
    inject_model_parser_test(specs, paths, binding)

    specs
  end

  def json_to_elixir_type("string"), do: "String.t()"
  def json_to_elixir_type("1"), do: "boolean()"
  def json_to_elixir_type(_), do: "any()"

  def list_or_nil(val) when is_list(val), do: "[]"
  def list_or_nil(_val), do: "nil"

  defp enhance_bindings(bindings) do
    Keyword.merge(bindings,
      json_to_elixir_type: &json_to_elixir_type/1,
      list_or_nil: &list_or_nil/1
    )
  end

  defp inject_model(%ModelSpecs{file: file}, paths, binding) do
    Mix.Generator.create_file(
      file,
      Mix.ExLemonway.eval_from(paths, "priv/templates/specs.gen.model/model.ex", binding)
    )
  end

  defp inject_model_parser(%ModelSpecs{dir: dir}, paths, binding) do
    parser_file = dir <> "/parser.ex"

    Mix.Generator.create_file(
      parser_file,
      Mix.ExLemonway.eval_from(paths, "priv/templates/specs.gen.model/model_parser.ex", binding)
    )
  end

  defp inject_model_parser_test(%ModelSpecs{test_dir: test_dir}, paths, binding) do
    parser_test_file = test_dir <> "/parser_test.exs"

    Mix.Generator.create_file(
      parser_test_file,
      Mix.ExLemonway.eval_from(
        paths,
        "priv/templates/specs.gen.model/model_parser_test.ex",
        binding
      )
    )
  end

  defp inject_test_factory(%ModelSpecs{test_factory_file: test_factory_file}, paths, binding) do
    Mix.Generator.create_file(
      test_factory_file,
      Mix.ExLemonway.eval_from(paths, "priv/templates/specs.gen.model/model_factory.ex", binding)
    )
  end

  defp prompt_for_code_injection(%ModelSpecs{} = specs) do
    if ModelSpecs.pre_existing?(specs) do
      function_count = ModelSpecs.function_count(specs)

      Mix.shell().info("""
      You are generating into an existing model.

      The #{inspect(specs.module)} model currently has #{function_count} functions.

      If you are not sure, prefer creating a new model over adding to the existing one.
      """)

      unless Mix.shell().yes?("Would you like to proceed?") do
        System.halt()
      end
    end
  end
end
