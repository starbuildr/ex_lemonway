defmodule Mix.Tasks.Specs.Gen.Endpoint do
  @shortdoc "Generates Elixir endpoints based on specs in specs/directkit/endpoint folder"

  use Mix.Task
  alias Mix.ExLemonway.EndpointSpecs

  @impl Mix.Task
  @shortdoc "Generate endpoint file based on JSON specs with related tests"
  @spec run([String.t()]) :: any()
  def run(args) do
    specs = EndpointSpecs.build(args)
    paths = Mix.ExLemonway.generator_paths()
    bindings = enhance_bindings(specs: specs)

    prompt_for_code_injection(specs)

    specs
    |> copy_new_files(paths, bindings)
  end

  def copy_new_files(%EndpointSpecs{} = specs, paths, binding) do
    inject_endpoint(specs, paths, binding)
    inject_endpoint_test(specs, paths, binding)

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

  defp inject_endpoint(%EndpointSpecs{file: file}, paths, binding) do
    Mix.Generator.create_file(
      file,
      Mix.ExLemonway.eval_from(paths, "priv/templates/specs.gen.endpoint/endpoint.ex", binding)
    )
  end

  defp inject_endpoint_test(%EndpointSpecs{test_file: test_file}, paths, binding) do
    Mix.Generator.create_file(
      test_file,
      Mix.ExLemonway.eval_from(
        paths,
        "priv/templates/specs.gen.endpoint/endpoint_test.ex",
        binding
      )
    )
  end

  defp prompt_for_code_injection(%EndpointSpecs{} = specs) do
    if EndpointSpecs.pre_existing?(specs) do
      function_count = EndpointSpecs.function_count(specs)

      Mix.shell().info("""
      You are generating into an existing endpoint.

      The #{inspect(specs.module)} endpoint currently has #{function_count} functions.

      If you are not sure, prefer creating a new endpoint over adding to the existing one.
      """)

      unless Mix.shell().yes?("Would you like to proceed?") do
        System.halt()
      end
    end
  end
end
