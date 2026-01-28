defmodule Segment.Config do
  @moduledoc false

  use TypedStruct

  @boolean_keys ~w(disable_meta_logger drop_nil_fields)a
  @float_keys ~w(retry_jitter_factor)a
  @integer_keys ~w(max_retries request_timeout retry_base_delay retry_max_delay)a

  @replacement "[FILTERED]"

  @filter_body [
    {~r/"address":\s?{.*?}/, ~s("address":{})},
    {~s("email":\s?".*"), ~s("email":"#{@replacement}")},
    {~s("first_name":\s?".*"), ~s("first_name":"#{@replacement}")},
    {~s("last_name":\s?".*"), ~s("last_name":"#{@replacement}")},
    {~s("phone_number":\s?".*"), ~s("phone_number":"#{@replacement}")}
  ]

  typedstruct do
    field :disable_meta_logger, boolean(), default: false
    field :drop_nil_fields, boolean(), default: false
    field :endpoint, String.t(), default: "https://api.segment.io/v1/"
    field :filter_body, Segment.filter_body()
    field :http_adapter, module(), default: Tesla.Adapter.Hackney
    field :key, String.t()
    field :max_retries, non_neg_integer(), default: 5
    field :prefix, atom() | String.t(), default: Segment.Analytics
    field :request_timeout, non_neg_integer(), default: 5_000
    field :retry_base_delay, non_neg_integer(), default: 200
    field :retry_jitter_factor, float(), default: 0.2
    field :retry_max_delay, non_neg_integer(), default: 5_000
  end

  @spec boolean_keys :: [atom()]
  def boolean_keys, do: @boolean_keys

  @spec default_filter_body :: Segment.filter_body()
  def default_filter_body, do: @filter_body

  @spec float_keys :: [atom()]
  def float_keys, do: @float_keys

  @spec get :: t()
  @spec get(Segment.options()) :: t()
  def get(fields \\ []) do
    :segment
    |> Application.get_all_env()
    |> reject_nil_values()
    |> Keyword.merge(reject_nil_values(fields))
    |> Keyword.new(&parse/1)
    |> then(&struct(__MODULE__, &1))
  end

  @spec integer_keys :: [atom()]
  def integer_keys, do: @integer_keys

  @spec keys :: [atom()]
  def keys do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
  end

  @spec reject_nil_values(Keyword.t()) :: Keyword.t()
  defp reject_nil_values(keywords),
    do: Keyword.reject(keywords, fn {_key, value} -> is_nil(value) end)

  @spec parse({atom(), any()}) :: {atom(), any()}
  defp parse({key, value}) when is_binary(value) do
    value =
      cond do
        key in @boolean_keys -> value == "true"
        key in @float_keys -> String.to_float(value)
        key in @integer_keys -> String.to_integer(value)
        true -> value
      end

    {key, value}
  end

  defp parse(key_value), do: key_value
end
