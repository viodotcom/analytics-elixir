defmodule Segment.ConfigTest do
  use ExUnit.Case, async: true

  alias Segment.Config, as: Subject

  @default_config %Subject{http_adapter: Tesla.Mock, key: "my-amazing-key"}

  describe "get/0" do
    test "returns default config" do
      assert Subject.get() == @default_config
    end
  end

  describe "get/1" do
    test "with empty options, returns default config" do
      assert Subject.get([]) == @default_config
    end

    for key <- Subject.keys() do
      @tag options: [{key, :value}], result: struct!(@default_config, [{key, :value}])
      test "returns config with updated #{inspect(key)} value", context do
        assert Subject.get(context.options) == context.result
      end

      @tag options: [{key, nil}], result: @default_config
      test "ignores nil #{inspect(key)}, returns default config", context do
        assert Subject.get(context.options) == context.result
      end
    end

    for key <- Subject.boolean_keys() do
      @tag options: [{key, "true"}], result: struct!(@default_config, [{key, true}])
      test "returns config with parsed true string for #{inspect(key)}", context do
        assert Subject.get(context.options) == context.result
      end

      @tag options: [{key, "untrue"}], result: struct!(@default_config, [{key, false}])
      test "returns config with parsed untrue string for #{inspect(key)}", context do
        assert Subject.get(context.options) == context.result
      end
    end

    for key <- Subject.float_keys() do
      @tag options: [{key, "0.2"}], result: struct!(@default_config, [{key, 0.2}])
      test "returns config with parsed string for #{inspect(key)}", context do
        assert Subject.get(context.options) == context.result
      end
    end

    for key <- Subject.integer_keys() do
      @tag options: [{key, "10000"}], result: struct!(@default_config, [{key, 10_000}])
      test "returns config with parsed string for #{inspect(key)}", context do
        assert Subject.get(context.options) == context.result
      end
    end
  end
end
