defmodule Segment.AnalyticsTest do
  # Required to be sync in order to isolate logs
  # and so that the created process can use the global Tesla adapter.
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog
  import Tesla.Mock

  alias Segment.Analytics, as: Subject

  @default_event %Segment.Analytics.Track{
    userId: nil,
    event: "test1",
    properties: %{},
    context: %Segment.Analytics.Context{}
  }

  @version Mix.Project.get().project[:version]

  @default_request_body %{
    "batch" => [
      %{
        "anonymousId" => nil,
        "context" => %{
          "app" => nil,
          "ip" => nil,
          "library" => %{
            "name" => "analytics_elixir",
            "transport" => "http",
            "version" => @version
          },
          "location" => nil,
          "os" => nil,
          "page" => nil,
          "referrer" => nil,
          "screen" => nil,
          "timezone" => nil,
          "traits" => nil,
          "userAgent" => nil
        },
        "event" => "test1",
        "properties" => %{},
        "timestamp" => nil,
        "type" => "track",
        "userId" => nil,
        "version" => nil
      }
    ]
  }

  @mocked_response_body Poison.encode!(%{
                          "another" => %{"json" => ["response"]},
                          "address" => %{"city" => "Amsterdam"}
                        })

  describe "call/2" do
    test "sends an event, and returns the response" do
      mock_request(@default_request_body, {200, [], @mocked_response_body})

      assert_call_result(@default_event, {:ok, @mocked_response_body}, [
        [
          "[info] [Segment.Analytics.HTTP] POST https://api.segment.io/v1/",
          ~s({"x-api-key", "[FILTERED]"}])
        ],
        "[info] [Segment.Analytics.HTTP] {",
        "[info] [Segment.Analytics.HTTP] 200",
        ["[info] [Segment.Analytics.HTTP] {", ~s("address":{})]
      ])
    end

    test "when `drop_nil_fields` option is set to `true`, sends an event without " <>
           "null JSON attributes, and returns the response" do
      mock_request(
        %{
          "batch" => [
            %{
              "context" => %{
                "library" => %{
                  "name" => "analytics_elixir",
                  "transport" => "http",
                  "version" => @version
                }
              },
              "event" => "test1",
              "properties" => %{},
              "type" => "track"
            }
          ]
        },
        {200, [], @mocked_response_body}
      )

      assert_call_result(
        @default_event,
        [drop_nil_fields: true],
        {:ok, @mocked_response_body},
        [
          [
            "[info] [Segment.Analytics.HTTP] POST https://api.segment.io/v1/",
            ~s({"x-api-key", "[FILTERED]"}])
          ],
          "[info] [Segment.Analytics.HTTP] {",
          "[info] [Segment.Analytics.HTTP] 200",
          ["[info] [Segment.Analytics.HTTP] {", ~s("address":{})]
        ]
      )
    end

    test "sends an event using endpoint and key from options, and returns the response" do
      mock_request(@default_request_body, {200, [], @mocked_response_body})

      assert_call_result(
        @default_event,
        [endpoint: "https://some-other-endpoint.vio.io/", key: "anotherkey"],
        {:ok, @mocked_response_body},
        [
          [
            "[info] [Segment.Analytics.HTTP] POST https://some-other-endpoint.vio.io/",
            ~s({"x-api-key", "[FILTERED]"}])
          ],
          "[info] [Segment.Analytics.HTTP] {",
          "[info] [Segment.Analytics.HTTP] 200",
          ["[info] [Segment.Analytics.HTTP] {", ~s("address":{})]
        ]
      )
    end

    test "when failed to reach the server, returns error" do
      mock_request(@default_request_body, {:error, :nxdomain})

      assert_call_result(@default_event, [max_retries: 0], {:error, ":nxdomain"}, [
        [
          "[info] [Segment.Analytics.HTTP] POST https://api.segment.io/v1/",
          ~s({"x-api-key", "[FILTERED]"}])
        ],
        "[info] [Segment.Analytics.HTTP] {",
        "[error] [Segment.Analytics.HTTP] :nxdomain",
        "[error] [Elixir.Segment.Analytics] Segment API request failed"
      ])
    end
  end

  defp mock_request(expected_request_body, response) do
    mock_global(fn %Tesla.Env{} = env ->
      request_body =
        env.body
        |> Poison.decode!()
        |> Map.delete("sentAt")
        |> Map.update!("batch", &Enum.map(&1, fn event -> Map.delete(event, "messageId") end))

      assert request_body == expected_request_body

      response
    end)
  end

  defp assert_call_result(event, expected_result, expected_logs) do
    # asserts call/1
    assert_call_result(event, nil, expected_result, expected_logs)
    # asserts call/2
    assert_call_result(event, [], expected_result, expected_logs)
  end

  defp assert_call_result(event, options, expected_result, expected_logs) do
    fn ->
      result =
        case options do
          nil -> Subject.call(event)
          options -> Subject.call(event, options)
        end

      assert %Task{} = task = result

      assert Task.await(task) == expected_result
    end
    |> capture_log()
    |> String.replace([IO.ANSI.normal(), IO.ANSI.red(), IO.ANSI.reset()], "")
    |> String.split("\n", trim: true)
    |> Enum.zip(List.wrap(expected_logs))
    |> Enum.each(fn {log, expected_log_substrings} ->
      for expected_log_substring <- List.wrap(expected_log_substrings) do
        assert log =~ expected_log_substring
      end
    end)
  end
end
