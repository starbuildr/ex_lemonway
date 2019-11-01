defmodule Mix.ExLemonway do
  @moduledoc """
  Conveniences for Lemonway tasks.

  Heavily inspired, sometimes directly copied from Phoenix:
  https://github.com/phoenixframework/phoenix
  """

  @doc """
  Evals EEx files from source dir.

  Files are evaluated against EEx according to
  the given binding.
  """
  def eval_from(apps, source_file_path, binding) do
    sources = Enum.map(apps, &to_app_source(&1, source_file_path))

    content =
      Enum.find_value(sources, fn source ->
        File.exists?(source) && File.read!(source)
      end) || raise "could not find #{source_file_path} in any of the sources"

    EEx.eval_string(content, binding, trim: true)
  end

  @doc """
  Copies files from source dir to target dir
  according to the given map.

  Files are evaluated against EEx according to
  the given binding.
  """
  def copy_from(apps, source_dir, binding, mapping) when is_list(mapping) do
    roots = Enum.map(apps, &to_app_source(&1, source_dir))

    for {format, source_file_path, target} <- mapping do
      source =
        Enum.find_value(roots, fn root ->
          source = Path.join(root, source_file_path)
          if File.exists?(source), do: source
        end) || raise "could not find #{source_file_path} in any of the sources"

      case format do
        :text ->
          Mix.Generator.create_file(target, File.read!(source))

        :eex ->
          Mix.Generator.create_file(target, EEx.eval_file(source, binding))

        :new_eex ->
          if File.exists?(target) do
            :ok
          else
            Mix.Generator.create_file(target, EEx.eval_file(source, binding))
          end
      end
    end
  end

  defp to_app_source(path, source_dir) when is_binary(path),
    do: Path.join(path, source_dir)

  defp to_app_source(app, source_dir) when is_atom(app),
    do: Application.app_dir(app, source_dir)

  @doc """
  Inflects path, scope, alias and more from the given name.

  ## Examples

      iex> Mix.ExLemonway.inflect("user")
      [alias: "User",
       human: "User",
       base: "ExLemonway",
       module: "ExLemonway.User",
       scoped: "User",
       singular: "user",
       path: "user"]

      iex> Mix.ExLemonway.inflect("Admin.User")
      [alias: "User",
       human: "User",
       base: "ExLemonway",
       module: "ExLemonway.Admin.User",
       scoped: "Admin.User",
       singular: "user",
       path: "admin/user"]

      iex> Mix.ExLemonway.inflect("Admin.SuperUser")
      [alias: "SuperUser",
       human: "Super user",
       base: "ExLemonway",
       module: "ExLemonway.Admin.SuperUser",
       scoped: "Admin.SuperUser",
       singular: "super_user",
       path: "admin/super_user"]

  """
  def inflect(singular) do
    base = Mix.ExLemonway.base()
    scoped = Macro.camelize(singular)
    path = Macro.underscore(scoped)
    singular = String.split(path, "/") |> List.last()
    module = Module.concat(base, scoped) |> inspect()
    alias = String.split(module, ".") |> List.last()
    human = humanize(singular)

    [
      alias: alias,
      human: human,
      base: base,
      module: module,
      scoped: scoped,
      singular: singular,
      path: path
    ]
  end

  @doc """
  Converts an attribute/form field into its humanize version.

  ## Examples

      iex> Mix.ExLemonway.humanize(:username)
      "Username"
      iex> Mix.ExLemonway.humanize(:created_at)
      "Created at"
      iex> Mix.ExLemonway.humanize("user_id")
      "User"

  """
  @spec humanize(atom | String.t()) :: String.t()
  def humanize(atom) when is_atom(atom),
    do: humanize(Atom.to_string(atom))

  def humanize(bin) when is_binary(bin) do
    bin =
      if String.ends_with?(bin, "_id") do
        binary_part(bin, 0, byte_size(bin) - 3)
      else
        bin
      end

    bin |> String.replace("_", " ") |> String.capitalize()
  end

  @doc """
  Checks the availability of a given module name.
  """
  def check_module_name_availability!(name) do
    name = Module.concat(Elixir, name)

    if Code.ensure_loaded?(name) do
      Mix.raise("Module name #{inspect(name)} is already taken, please choose another name")
    end
  end

  @doc """
  Returns the module base name based on the configuration value.

      config :my_app
        namespace: My.App

  """
  def base do
    app_base(otp_app())
  end

  defp app_base(app) do
    case Application.get_env(app, :namespace, app) do
      ^app -> app |> to_string() |> Macro.camelize()
      mod -> mod |> inspect()
    end
  end

  @doc """
  Returns the OTP app from the Mix project configuration.
  """
  def otp_app do
    Mix.Project.config() |> Keyword.fetch!(:app)
  end

  @doc """
  Returns all compiled modules in a project.
  """
  def modules do
    Mix.Project.compile_path()
    |> Path.join("*.beam")
    |> Path.wildcard()
    |> Enum.map(&beam_to_module/1)
  end

  defp beam_to_module(path) do
    path |> Path.basename(".beam") |> String.to_atom()
  end

  @doc """
  The paths to look for template files for generators.

  Defaults to checking the current app's `priv` directory,
  and falls back to Phoenix's `priv` directory.
  """
  def generator_paths do
    [".", :ex_lemonway]
  end

  @doc """
  Returns the context app path prefix to be used in generated context files.
  """
  def opt_app_path(rel_path) do
    rel_path
  end

  @doc """
  Returns the model lib path to be used in generated model files.
  """
  def model_lib_path(rel_path) do
    opt_app_path(Path.join(["lib", "model", rel_path]))
  end

  @doc """
  Returns the model test path to be used in generated model files.
  """
  def model_test_path(rel_path) do
    this_app = otp_app()
    opt_app_path(Path.join(["test", "#{this_app}", "model", rel_path]))
  end

  @doc """
  Returns the model factory test path to be used in tests with generated model files.
  """
  def factory_test_path(rel_path) do
    opt_app_path(Path.join(["test", "support", "factory", rel_path]))
  end

  @doc """
  Returns the context specs path to be used in generated model files.
  """
  def model_specs_path(rel_path) do
    opt_app_path(Path.join(["specs", "directkit", "model", rel_path]))
  end

  @doc """
  Returns the endpoint lib path to be used in generated files.
  """
  def endpoint_lib_path(rel_path) do
    opt_app_path(Path.join(["lib", "endpoint", rel_path]))
  end

  @doc """
  Returns the endpoint test path to be used in generated endpoint files.
  """
  def endpoint_test_path(rel_path) do
    this_app = otp_app()
    opt_app_path(Path.join(["test", "#{this_app}", "endpoint", rel_path]))
  end

  @doc """
  Returns the context specs paths to be used in generated endpoint files.
  """
  def endpoint_specs_path(:request, rel_path) do
    opt_app_path(Path.join(["specs", "directkit", "endpoint", rel_path, "request.json"]))
  end

  def endpoint_specs_path(:response, rel_path) do
    opt_app_path(Path.join(["specs", "directkit", "endpoint", rel_path, "response.json"]))
  end

  @doc """
  Returns the test prefix to be used in generated file specs.
  """
  def test_path(rel_path \\ "") do
    this_app = otp_app()
    Path.join(["test", "#{this_app}", rel_path])
  end

  @doc """
  Prompts to continue if any files exist.
  """
  def prompt_for_conflicts(generator_files) do
    file_paths = Enum.map(generator_files, fn {_, _, path} -> path end)

    case Enum.filter(file_paths, &File.exists?(&1)) do
      [] ->
        :ok

      conflicts ->
        Mix.shell().info("""
        The following files conflict with new files to be generated:

        #{conflicts |> Enum.map(&"  * #{&1}") |> Enum.join("\n")}

        See the --web option to namespace similarly named resources
        """)

        unless Mix.shell().yes?("Proceed with interactive overwrite?") do
          System.halt()
        end
    end
  end
end
