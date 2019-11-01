defmodule ExLemonway.Behaviour.HttpClient do
  @moduledoc """
  Behaviour for making HTTP requests, to be implemented by adapters.
  """

  @type response :: {:ok, nil | map() | String.t()} | {:error, HttpError.t()}

  defmodule HttpError do
    defexception message: "HTTP request failed", code: nil, data: nil

    def new(message, code \\ nil, data \\ nil) do
      %__MODULE__{
        message: message,
        code: code,
        data: data
      }
    end
  end

  @doc """
  HTTP GET request, all payload is URL encoded.
  """
  @callback get(String.t(), Keyword.t(), Keyword.t()) :: response

  @doc """
  HTTP PUT request.
  """
  @callback put(String.t(), map(), Keyword.t(), Keyword.t()) :: response

  @doc """
  HTTP POST request.
  """
  @callback post(String.t(), map(), Keyword.t(), Keyword.t()) :: response

  @doc """
  HTTP DELETE request.
  """
  @callback delete(String.t(), Keyword.t(), Keyword.t()) :: response

  defmacro __using__(_opts) do
    http_client = Application.fetch_env!(:ex_lemonway, :http_client)

    quote do
      defdelegate get(url), to: unquote(http_client)
      defdelegate get(url, headers), to: unquote(http_client)
      defdelegate get(url, headers, opts), to: unquote(http_client)

      defdelegate put(url, payload), to: unquote(http_client)
      defdelegate put(url, payload, headers), to: unquote(http_client)
      defdelegate put(url, payload, headers, opts), to: unquote(http_client)

      defdelegate post(url, payload), to: unquote(http_client)
      defdelegate post(url, payload, headers), to: unquote(http_client)
      defdelegate post(url, payload, headers, opts), to: unquote(http_client)

      defdelegate delete(url), to: unquote(http_client)
      defdelegate delete(url, headers), to: unquote(http_client)
      defdelegate delete(url, headers, opts), to: unquote(http_client)
    end
  end
end
