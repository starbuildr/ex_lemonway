defmodule Mix.ExLemonway.ModelSpecs do
  @moduledoc """
  Generator scope with data useful for model file generation.

  Heavily inspired, sometimes directly copied from Phoenix:
  https://github.com/phoenixframework/phoenix
  """

  alias Mix.ExLemonway.ModelSpecs

  @lemonway_atomic_types [
    "string",
    "1",
    "boolean",
    "sddMandateId",
    "status",
    "iban",
    "swiftCode",
    "ip",
    "email",
    "country",
    "phone_number"
  ]
  def lemonway_atomic_types, do: @lemonway_atomic_types

  defstruct name: nil,
            module: nil,
            alias: nil,
            base_module: nil,
            singular: nil,
            basename: nil,
            file: nil,
            test_dir: nil,
            test_file: nil,
            test_factory_file: nil,
            dir: nil,
            specs_file: nil,
            specs_fields: %{},
            generate?: true,
            opt_app: nil,
            lemonway_atomic_types: @lemonway_atomic_types,
            opts: []

  @spec valid?(String.t()) :: boolean()
  def valid?(model_name) do
    model_name =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/
  end

  @spec new!(String.t(), Keyword.t()) :: Mix.ExLemonway.ModelSpecs.t() | no_return
  def new!(model_name, opts) do
    opt_app = opts[:opt_app] || Mix.ExLemonway.otp_app()
    base = Module.concat([Mix.ExLemonway.base()])
    module = Module.concat(base, model_name)
    alias = Module.concat([module |> Module.split() |> List.last()])
    basedir = Macro.underscore(model_name)
    basename = Path.basename(basedir)
    dir = Mix.ExLemonway.model_lib_path(basedir)
    file = dir <> ".ex"
    test_dir = Mix.ExLemonway.model_test_path(basedir)
    test_file = test_dir <> "_test.exs"
    test_factory_file = Mix.ExLemonway.factory_test_path("#{basename}_factory") <> ".ex"
    basefile = Macro.underscore(model_name) <> ".json"
    specs_file = Mix.ExLemonway.model_specs_path(basefile)
    specs_fields = parse_specs_file!(specs_file)
    generate? = Keyword.get(opts, :model, true)

    %ModelSpecs{
      name: model_name,
      module: module,
      alias: alias,
      base_module: base,
      basename: basename,
      file: file,
      test_dir: test_dir,
      test_file: test_file,
      test_factory_file: test_factory_file,
      dir: dir,
      specs_file: specs_file,
      specs_fields: specs_fields,
      generate?: generate?,
      opt_app: opt_app,
      opts: opts
    }
  end

  @spec build([String.t()]) :: Mix.ExLemonway.Context.t() | no_return
  def build([model_name | _] = _args) do
    unless valid?(model_name), do: invalid_model_name!()

    new!(model_name, [])
  end

  def build(_args), do: invalid_model_name!()

  def pre_existing?(%ModelSpecs{file: file}), do: File.exists?(file)

  def pre_existing_tests?(%ModelSpecs{test_file: file}), do: File.exists?(file)

  def function_count(%ModelSpecs{file: file}) do
    {_ast, count} =
      file
      |> File.read!()
      |> Code.string_to_quoted!()
      |> Macro.postwalk(0, fn
        {:def, _, _} = node, count -> {node, count + 1}
        node, count -> {node, count}
      end)

    count
  end

  defp parse_specs_file!(specs_file) do
    specs_file
    |> File.read!()
    |> Jason.decode!()
    |> json_to_fields()
  end

  defp json_to_fields(json) do
    json
  end

  @spec invalid_model_name!() :: no_return
  defp invalid_model_name! do
    Mix.raise("""
    Invalid model name, should follow CamelCase pattern in naming.

      mix specs.gen.model Wallet
    """)
  end
end
