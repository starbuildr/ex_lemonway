defmodule ExLemonway.Factory do
  use ExLemonway.Factory.Helpers, "./test/support/factory"

  @spec build(atom() | String.t(), map()) :: map()
  def build(model, params \\ %{}) do
    fun = "#{model}_factory" |> String.to_atom()
    apply(__MODULE__, fun, [params])
  end
end
