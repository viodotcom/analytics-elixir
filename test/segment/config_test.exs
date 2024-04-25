defmodule Segment.ConfigTest do
  use ExUnit.Case, async: true

  alias Segment.Config, as: Subject

  @default_config %Subject{http_adapter: Tesla.Mock, key: "my-amazing-key"}
  @keys %Subject{}
        |> Map.from_struct()
        |> Map.keys()
        |> Enum.sort()

  describe "get/0" do
    test "returns default config" do
      assert Subject.get() == @default_config
    end
  end

  describe "get/1" do
    test "with empty options, returns default config" do
      assert Subject.get() == @default_config
    end

    for key <- @keys do
      @tag options: [{key, :value}]
      test "returns config with updated #{inspect(key)}", %{options: options} do
        assert Subject.get(options) == struct!(@default_config, options)
      end

      @tag options: [{key, nil}]
      test "ignores nil #{inspect(key)}, returns default config", %{options: options} do
        assert Subject.get(options) == @default_config
      end
    end
  end
end
