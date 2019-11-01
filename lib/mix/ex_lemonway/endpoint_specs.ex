defmodule Mix.ExLemonway.EndpointSpecs do
  @moduledoc """
  Generator scope with data useful for endpoint file generation.

  Heavily inspired, sometimes directly copied from Phoenix:
  https://github.com/phoenixframework/phoenix
  """

  alias Mix.ExLemonway.EndpointSpecs

  @lemonway_atomic_types Mix.ExLemonway.ModelSpecs.lemonway_atomic_types()

  defstruct name: nil,
            module: nil,
            alias: nil,
            base_module: nil,
            basename: nil,
            file: nil,
            test_dir: nil,
            test_file: nil,
            dir: nil,
            specs_req_file: nil,
            specs_req_fields: %{},
            specs_res_file: nil,
            specs_res_fields: %{},
            generate?: true,
            opt_app: nil,
            lemonway_atomic_types: @lemonway_atomic_types,
            opts: []

  @spec valid?(String.t()) :: boolean()
  def valid?(endpoint_name) do
    endpoint_name =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/
  end

  @spec new!(String.t(), Keyword.t()) :: EndpointSpecs.t() | no_return
  def new!(endpoint_name, opts) do
    opt_app = opts[:opt_app] || Mix.ExLemonway.otp_app()
    base = Module.concat([Mix.ExLemonway.base()])
    module = Module.concat([base, Endpoint, endpoint_name])
    alias = Module.concat([module |> Module.split() |> List.last()])
    basedir = Macro.underscore(endpoint_name)
    basename = Path.basename(basedir)
    dir = Mix.ExLemonway.endpoint_lib_path(basedir)
    file = dir <> ".ex"
    test_dir = Mix.ExLemonway.endpoint_test_path(basedir)
    test_file = test_dir <> "_test.exs"
    basefile = Macro.underscore(endpoint_name)
    specs_req_file = Mix.ExLemonway.endpoint_specs_path(:request, basefile)
    specs_req_fields = parse_specs_file!(specs_req_file)
    specs_res_file = Mix.ExLemonway.endpoint_specs_path(:response, basefile)
    specs_res_fields = parse_specs_file!(specs_res_file)
    generate? = Keyword.get(opts, :model, true)

    %EndpointSpecs{
      name: endpoint_name,
      module: module,
      alias: alias,
      base_module: base,
      basename: basename,
      file: file,
      test_dir: test_dir,
      test_file: test_file,
      dir: dir,
      specs_req_file: specs_req_file,
      specs_req_fields: specs_req_fields,
      specs_res_file: specs_res_file,
      specs_res_fields: specs_res_fields,
      generate?: generate?,
      opt_app: opt_app,
      opts: opts
    }
  end

  @spec build([String.t()]) :: Mix.ExLemonway.Context.t() | no_return
  def build([endpoint_name | _] = _args) do
    unless valid?(endpoint_name), do: invalid_endpoint_name!()

    new!(endpoint_name, [])
  end

  def build(_args), do: invalid_endpoint_name!()

  def pre_existing?(%EndpointSpecs{file: file}), do: File.exists?(file)

  def pre_existing_tests?(%EndpointSpecs{test_file: file}), do: File.exists?(file)

  def function_count(%EndpointSpecs{file: file}) do
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

  @spec invalid_endpoint_name!() :: no_return
  defp invalid_endpoint_name! do
    Mix.raise("""
    Invalid model name, should follow CamelCase pattern in naming.

      mix specs.gen.endpoint GetWalletDetails
    """)
  end
end
