defmodule <%= inspect specs.module %>Factory do
  @moduledoc """
  Factory for <%= specs.name %>.

  It's automatically generated by `mix specs.gen.model <%= specs.name %>`
  Dont' edit this file manually, to make any changes, please update:
  `<%= specs.specs_file %>`
  """

  alias <%= inspect specs.module %>

  <% lp = "\n          " %>
  <% fields = for {field, [_subtype]} <- specs.specs_fields do
    Macro.underscore(field) <> ": []"
  end %>
  <% fields = for {field, subtype} when is_binary(subtype) <- specs.specs_fields do
    unless subtype in specs.lemonway_atomic_types do
      Macro.underscore(field) <> ": ExLemonway.Factory.build(:#{Macro.underscore(subtype)})"
    else
      Macro.underscore(field) <> ": " <> ~s[gen_value("#{subtype}", "#{field}", id)]
    end
  end |> Kernel.++(fields) %>
  <% fields = Enum.filter(fields, & &1 !== nil) %>
  defmacro __using__(_opts) do
    quote do
      def <%= specs.basename %>_factory(params \\ %{}) do
        id = id(<%= inspect(specs.module) %>Factory)
        %<%= specs.name %>{<%= lp <> Enum.join(fields, ",#{lp}") %>
        } |> Map.merge(params)
      end
    end
  end
end