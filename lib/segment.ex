defmodule Segment do
  @moduledoc """
  Client for Segment API.

  For usage, see `Segment.Analytics`.

  For options and configuration, see `t:Segment.options/0`.
  """

  @default_config %Segment.Config{}

  @typedoc "The struct that will be used as payload."
  @type model :: struct()

  @typedoc "Request and response body patterns that will be filtered before logging."
  @type filter_body :: [{Regex.t() | String.pattern(), String.t()}]

  @typedoc "HTTP headers that will be filtered before logging."
  @type filter_headers :: [String.t()]

  @typedoc """
  Options to customize the operation.

  It is possible to define options through application environment:

      # in config.exs
      import Config

      config :segment,
        disable_meta_logger: #{inspect(@default_config.disable_meta_logger)},
        drop_nil_fields: #{inspect(@default_config.drop_nil_fields)},
        endpoint: #{inspect(@default_config.endpoint)},
        filter_body: #{inspect(@default_config.filter_body)},
        http_adapter: #{inspect(@default_config.http_adapter)},
        key: "a-valid-api-key",
        max_retries: #{inspect(@default_config.max_retries)},
        prefix: #{inspect(@default_config.prefix)},
        request_timeout: #{inspect(@default_config.request_timeout)},
        retry_base_delay: #{inspect(@default_config.retry_base_delay)},
        retry_jitter_factor: #{inspect(@default_config.retry_jitter_factor)},
        retry_max_delay: #{inspect(@default_config.retry_max_delay)}

  Available options:

  - `:disable_meta_logger` - If `true`, the request and response will not be logged.
    Defaults to `#{inspect(@default_config.disable_meta_logger)}`.
  - `:drop_nil_fields` - If `true`, removes any field with `nil` value from the request payload.
    Defaults to `#{inspect(@default_config.drop_nil_fields)}`.
  - `:endpoint` - The base URL for the Segment API.
    Defaults to `#{inspect(@default_config.endpoint)}`.
  - `:filter_body` - Request and response body patterns that will be filtered before logging.
    Defaults to `#{inspect(@default_config.filter_body)}`.
  - `:http_adapter` - `:Tesla` adapter for the client.
    Defaults to `#{inspect(@default_config.http_adapter)}`.
  - `:key` - The `x-api-key` HTTP header value.
    Must be set.
  - `:max_retries` - Maximum number of retries.
    Defaults to `#{inspect(@default_config.max_retries)}`.
  - `:prefix` - String or atom (including modules) to be used as the log prefix.
    Defaults to `#{inspect(@default_config.prefix)}`.
  - `:request_timeout` - Maximum amount of milliseconds to wait for a response.
    Defaults to `#{inspect(@default_config.request_timeout)}`.
  - `:retry_base_delay` - The base amount of milliseconds to wait before attempting a new request.
    Defaults to `#{inspect(@default_config.retry_base_delay)}`.
  - `:retry_jitter_factor` - Additive noise multiplier to update the retry delay.
    Defaults to `#{inspect(@default_config.retry_jitter_factor)}`.
  - `:retry_max_delay` - Maximum delay in milliseconds to wait before attempting a new request.
    Defaults to `#{inspect(@default_config.retry_max_delay)}`.

  """
  @type options :: [
          disable_meta_logger: boolean(),
          drop_nil_fields: boolean(),
          endpoint: String.t(),
          filter_body: Segment.filter_body(),
          http_adapter: module(),
          key: String.t(),
          max_retries: non_neg_integer(),
          prefix: atom() | String.t(),
          request_timeout: non_neg_integer(),
          retry_base_delay: non_neg_integer(),
          retry_jitter_factor: non_neg_integer(),
          retry_max_delay: non_neg_integer()
        ]
end
