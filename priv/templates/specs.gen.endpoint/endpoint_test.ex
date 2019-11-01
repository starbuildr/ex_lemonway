defmodule <%= inspect specs.module %>Test do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias ExLemonway.Factory.Helpers
  alias <%= inspect specs.module %>

  setup do
    parent_dir = Application.get_env(:exvcr, :vcr_cassette_library_dir)
    ExVCR.Config.cassette_library_dir("#{parent_dir}/lemonway")
    :ok
  end

  describe "&request/1" do
    test "should perform HTTP requests for valid payload" do
      use_cassette "<%= specs.name |> Macro.underscore() %>" do
        id = :os.system_time(:seconds)
        payload =
          %<%= specs.name %>.Request{
            <%= for {field, type} <- specs.specs_req_fields do %>
            <%= Macro.underscore(field) %>: Helpers.gen_value("<%= type %>", "<%= Macro.underscore(field) %>", id),
            <% end %>
          }
        assert {:ok, %<%= specs.name %>.Response{} = _response} = <%= specs.name %>.request(payload)
      end
    end
  end
end
