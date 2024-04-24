defmodule Segment.EncoderTest do
  use ExUnit.Case, async: true

  alias Segment.Encoder, as: Subject

  alias Segment.Config
  alias Segment.Support.Factory

  describe "encode!/2" do
    setup do
      batch = Factory.build(:batch)

      {:ok, batch: batch}
    end

    test "transforms a struct into a JSON string", %{batch: batch} do
      assert_encode!(batch, %Config{}, :batch)
    end

    test "when `drop_nil_fields` options is `true`, " <>
           "returns a JSON string without `null` attributes",
         %{batch: batch} do
      assert_encode!(batch, %Config{drop_nil_fields: true}, :batch_without_null)
    end

    test "when `drop_nil_fields` option is set to something different than `true`," <>
           "returns a JSON string with `null` attributes",
         %{batch: batch} do
      assert_encode!(batch, %Config{drop_nil_fields: "Please don't"}, :batch)
    end
  end

  defp assert_encode!(batch, %Config{} = config, result_factory) do
    # For OTP 26+, it is required to parse the encoded value back to map since the order is not
    # predictable.

    result = Subject.encode!(batch, config)

    assert Poison.decode!(result) == Factory.string_map_for(result_factory)
  end
end
