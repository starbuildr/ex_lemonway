defmodule <%= inspect specs.module %> do
  @moduledoc """
  Endpoint for <%= specs.name %>.

  It's automatically generated by `mix specs.gen.endpoint <%= specs.name %>`
  Dont' edit this file manually, to make any changes, please update:
  `<%= specs.specs_req_file %>`
  or `<%= specs.specs_res_file %>`
  """

  defmodule Request do
    <% lp = "\n      " %>
    <% fields = for {field, type} <- specs.specs_req_fields, do: Macro.underscore(field) <> ": #{list_or_nil.(type)}" %>
    defstruct [ <%= lp <> Enum.join(fields, ",#{lp}") %>
    ]

    @doc """
    Convert structured request into payload map according to specs.
    """
    @spec to_payload(Request.t()) :: map()
    def to_payload(%Request{} = data) do
      Enum.reduce(Map.from_struct(data), %{}, fn
        ({key, %{__struct__: model_module} = value}, payload) ->
          field = key_to_field(key)
          inner_payload = Module.concat(model_module, Parser).to_payload(value)
          Map.put(payload, field, inner_payload)

        ({key, value}, payload) ->
          Map.put(payload, key_to_field(key), value)
      end)
    end

    @doc """
    Convert raw string key into struct key atom.
    """
    @spec field_to_key(String.t()) :: atom()
    <%= for {field, type} when is_binary(type) <- specs.specs_req_fields do %>
    def field_to_key("<%= field %>"), do: :<%= Macro.underscore(field) %>
    <% end %>
    def field_to_key(_), do: nil

    @doc """
    Convert atomic key to original string key.
    """
    @spec key_to_field(atom()) :: String.t()
    <%= for {field, type} when is_binary(type) <- specs.specs_req_fields do %>
    def key_to_field(:<%= Macro.underscore(field) %>), do: "<%= field %>"
    <% end %>
  end

  defmodule Response do
    require Logger

    <% lp = "\n      " %>
    <% fields = for {field, type} <- specs.specs_res_fields, do: Macro.underscore(field) <> ": #{list_or_nil.(type)}" %>
    defstruct [ <%= lp <> Enum.join(fields, ",#{lp}") %>
    ]

    @lemonway_atomic_types Mix.ExLemonway.ModelSpecs.lemonway_atomic_types() |> Enum.map(&String.to_atom/1)

    # Some autogenerated responses may not have lemonway_atomic_types,
    # so that much is redundant and triggers warning, which does no harm.
    @dialyzer {:no_match, from_data: 1}

    @doc """
    Convert raw string key into struct key atom.
    """
    @spec field_to_key(String.t()) :: atom()
    <%= for {field, type} when is_binary(type) <- specs.specs_res_fields do %>
    def field_to_key("<%= field %>"), do: :<%= Macro.underscore(field) %>
    <% end %>
    def field_to_key(_), do: nil

    @doc """
    Convert atomic key to original string key.
    """
    @spec key_to_field(atom()) :: String.t()
    <%= for {field, type} when is_binary(type) <- specs.specs_res_fields do %>
    def key_to_field(:<%= Macro.underscore(field) %>), do: "<%= field %>"
    <% end %>

    @doc """
    Get expected type by a field name.
    """
    @spec field_type(String.t()) :: atom()
    <%= for {field, [subtype]} when is_binary(subtype) <- specs.specs_res_fields do %>
    def field_type("<%= field %>"), do: <%= subtype %>
    <% end %>
    <%= for {field, type} when is_binary(type) or is_list(type) <- specs.specs_res_fields do %>
    <%= cond do %>
    <% type === "1" -> %>
    def field_type("<%= field %>"), do: :boolean
    <% type in specs.lemonway_atomic_types -> %>
    def field_type("<%= field %>"), do: :<%= Macro.underscore(type) %>
    <% true -> %>
    def field_type("<%= field %>"), do: <%= type %>
    <% end %>
    <% end %>
    def field_type(_), do: :unknown

    @doc """
    Convert raw response to a Response struct.
    """
    @spec from_data(map()) :: {:ok, __MODULE__.t()} | {:error, :parsing_failed}
    def from_data(data) do
      IO.inspect(data)
      Enum.reduce_while(data, {:ok, %__MODULE__{}}, fn({field, value}, {:ok, response}) ->
        key = field_to_key(field)
        type = field_type(field)

        cond do
          is_list(value) ->
            parser = Module.concat([<%= specs.base_module %>, type, Parser])
            submodels =
              Enum.reduce_while(value, [], fn(raw_value, acc) ->
                case parser.to_struct(raw_value) do
                  {:ok, submodel} ->
                    {:cont, acc ++ [submodel]}

                  error ->
                    {:halt, error}
                end
              end)

            case submodels do
              submodels when is_list(submodels) ->
                {:cont, {:ok, Map.put(response, key, submodels)}}

              error ->
                {:halt, error}
            end

          type === :unknown ->
            Logger.warn "Uknown type for field '#{field}', skipped"
            {:cont, {:ok, response}}

          type in @lemonway_atomic_types ->
            {:cont, {:ok, Map.put(response, key, value)}}

          true ->
            parser = Module.concat([<%= specs.base_module %>, type, Parser])
            case parser.to_struct(value) do
              {:ok, submodel} ->
                {:cont, {:ok, Map.put(response, key, submodel)}}

              error ->
                {:halt, error}
            end
        end
      end)
    end
  end

  alias ExLemonway.Util
  alias ExLemonway.Behaviour.HttpClient

  @doc """
  Send API request to execute <%= specs.name %>.
  """
  @spec request(Request.t()) :: {:ok, Response.t()} | {:error, :parsing_failed | HttpClient.HttpError.t()}
  def request(%Request{} = data) do
    url = ExLemonway.config(:api_url) <> "/<%= specs.name %>"
    payload = Request.to_payload(data) |> ExLemonway.Util.Request.enhance_payload()

    with {:ok, %{"d" => response}} <- Util.Request.post(url, %{"p" => payload}) do
      case response do
        %{"E" => %{"Code" => code, "Msg" => message}} ->
          error = HttpClient.HttpError.new(message, String.to_integer(code))
          {:error, error}

        response ->
          Response.from_data(Map.drop(response, ["E", "__type"]))
      end
    end
  end
end