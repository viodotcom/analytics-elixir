defmodule Segment.Encoder do
  @moduledoc false

  alias Segment.Config

  @spec encode!(struct(), Config.t()) :: String.t()
  def encode!(struct, %Config{} = config) do
    struct
    |> Miss.Map.from_nested_struct([
      {Date, &Date.to_iso8601/1},
      {DateTime, &DateTime.to_iso8601/1},
      {Decimal, &Decimal.to_float/1}
    ])
    |> maybe_drop_nil_fields(config)
    |> Poison.encode!()
  end

  @spec maybe_drop_nil_fields(map(), Config.t()) :: map()
  defp maybe_drop_nil_fields(map, %Config{} = config) do
    if config.drop_nil_fields == true do
      drop_nil_fields_from_map(map)
    else
      map
    end
  end

  @spec drop_nil_fields_from_map(map()) :: map()
  def drop_nil_fields_from_map(map), do: Enum.reduce(map, %{}, &drop_nil_fields/2)

  @spec drop_nil_fields({any(), any()}, map()) :: map()
  defp drop_nil_fields({key, value}, map) when is_map(value),
    do: Map.put(map, key, drop_nil_fields_from_map(value))

  defp drop_nil_fields({key, [item | _items] = value}, map)
       when is_list(value) and is_map(item),
       do: Map.put(map, key, Enum.map(value, &drop_nil_fields_from_map/1))

  defp drop_nil_fields({_field, value}, map) when is_nil(value), do: map
  defp drop_nil_fields({key, value}, map), do: Map.put(map, key, value)
end
