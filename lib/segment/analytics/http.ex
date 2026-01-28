defmodule Segment.Analytics.HTTP do
  @moduledoc false

  alias Segment.Config
  alias Tesla.Middleware

  @type request_result :: {:ok, String.t()} | {:error, String.t()}

  defguardp response_ok?(value) when is_struct(value, Tesla.Env) and value.status in 200..299

  @spec post(String.t(), Config.t()) :: request_result()
  @spec post(String.t(), String.t(), Config.t()) :: request_result()
  def post(path \\ "", raw_body, %Config{} = config) do
    config
    |> client()
    |> Tesla.post(path, raw_body)
    |> handle_result()
  end

  @spec client(Config.t()) :: Tesla.Client.t()
  defp client(%Config{} = config) do
    # The order matters, see Tesla.Middleware
    [
      {Middleware.BaseUrl, config.endpoint},
      {Middleware.Headers, headers(config)},
      {Middleware.Retry, retry(config)},
      if(config.disable_meta_logger != true, do: {Middleware.MetaLogger, meta_logger(config)})
    ]
    |> Enum.reject(&is_nil/1)
    |> Tesla.client(adapter(config))
  end

  @spec headers(Config.t()) :: Tesla.Env.headers()
  defp headers(%Config{} = config) do
    [
      {"accept", "application/json"},
      {"content-Type", "application/json"},
      {"x-api-key", config.key}
    ]
  end

  @spec retry(Config.t()) :: Keyword.t()
  defp retry(%Config{} = config) do
    [
      delay: config.retry_base_delay,
      jitter_factor: config.retry_jitter_factor,
      max_delay: config.retry_max_delay,
      max_retries: config.max_retries,
      should_retry: &should_retry?/1
    ]
  end

  @spec should_retry?(Tesla.Env.result()) :: boolean()
  defp should_retry?({:ok, %Tesla.Env{} = env}) when response_ok?(env), do: false
  defp should_retry?(_result), do: true

  @spec meta_logger(Config.t()) :: Keyword.t()
  defp meta_logger(%Config{} = config) do
    [
      filter_body: config.filter_body || Config.default_filter_body(),
      filter_headers: ~w(x-api-key),
      log_level: :info,
      log_tag: __MODULE__
    ]
  end

  @spec adapter(Config.t()) :: {module(), recv_timeout: non_neg_integer()}
  defp adapter(%Config{} = config),
    do: {config.http_adapter, recv_timeout: config.request_timeout}

  @spec handle_result(Tesla.Env.result()) :: request_result()
  defp handle_result({:ok, %Tesla.Env{} = env}) when response_ok?(env), do: {:ok, env.body}
  defp handle_result({:ok, %Tesla.Env{} = env}), do: {:error, env.body}
  defp handle_result({:error, reason}), do: {:error, inspect(reason)}
end
