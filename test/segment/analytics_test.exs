defmodule Segment.AnalyticsTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  import Tesla.Mock

  alias Segment.Analytics, as: Subject

  @version Mix.Project.get().project[:version]

  describe "call/2" do
    test "sends an event, and returns the response" do
      response_body = mocked_response_body()
      mock_request(request_body_with_nil_values(), {200, [], response_body})
      assert_call_result({:ok, response_body}, successful_logs())
    end

    test "when `drop_nil_fields` option is set to `true`, sends an event without " <>
           "null JSON attributes, and returns the response" do
      response_body = mocked_response_body()
      mock_request(request_body_without_nil_values(), {200, [], response_body})
      assert_call_result([drop_nil_fields: true], {:ok, response_body}, successful_logs())
    end

    test "sends an event using endpoint and key from options, and returns the response" do
      response_body = mocked_response_body()
      mock_request(request_body_with_nil_values(), {200, [], response_body})

      endpoint = "https://some-other-endpoint.vio.io/"

      assert_call_result(
        [endpoint: endpoint, key: "anotherkey"],
        {:ok, response_body},
        successful_logs(endpoint)
      )
    end

    test "when failed to request, tries again" do
      response_body = mocked_response_body()

      mock_request(request_body_with_nil_values(), [
        {:error, :timeout},
        {:error, :timeout},
        {:error, :timeout},
        {200, [], response_body}
      ])

      assert_call_result(
        [retry_base_delay: 1],
        {:ok, response_body},
        retried_successful_logs(3, ":timeout")
      )
    end

    test "when failed to request and no retries left, returns error" do
      mock_request(request_body_with_nil_values(), {:error, :nxdomain})
      assert_call_result([max_retries: 0], {:error, ":nxdomain"}, failed_logs(":nxdomain"))
    end

    test "with meta logger disabled, does not log requests and responses" do
      response_body = mocked_response_body()

      mock_request(request_body_with_nil_values(), [
        {:error, :timeout},
        {200, [], response_body}
      ])

      # No logs whatsoever on success, even with retried requests
      assert_call_result(
        [disable_meta_logger: true, retry_base_delay: 1],
        {:ok, response_body},
        []
      )

      # Analytics still logs if no request succeeds.
      assert_call_result(
        [disable_meta_logger: true, max_retries: 0],
        {:error, ":timeout"},
        analytics_failed_logs()
      )
    end
  end

  defp mock_request(expected_request_body, responses) when is_list(responses) do
    mock_global(fn %Tesla.Env{} = env ->
      assert_request_body(env, expected_request_body)
      index = Process.get(:attempts, 0)
      Process.put(:attempts, index + 1)
      Enum.fetch!(responses, index)
    end)
  end

  defp mock_request(expected_request_body, response) do
    mock_global(fn %Tesla.Env{} = env ->
      assert_request_body(env, expected_request_body)
      response
    end)
  end

  defp assert_request_body(%Tesla.Env{} = env, expected_request_body) do
    request_body =
      env.body
      |> Poison.decode!()
      |> Map.delete("sentAt")
      |> Map.update!("batch", &Enum.map(&1, fn event -> Map.delete(event, "messageId") end))

    assert request_body == expected_request_body
  end

  defp assert_call_result(expected_result, expected_logs) do
    # asserts call/1
    assert_call_result(nil, expected_result, expected_logs)
    # asserts call/2
    assert_call_result([], expected_result, expected_logs)
  end

  defp assert_call_result(options, expected_result, expected_logs) do
    event = %Segment.Analytics.Track{
      userId: nil,
      event: "test1",
      properties: %{},
      context: %Segment.Analytics.Context{}
    }

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

  defp request_body_with_nil_values do
    %{
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
  end

  defp request_body_without_nil_values do
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
    }
  end

  defp mocked_response_body do
    Poison.encode!(%{
      "another" => %{"json" => ["response"]},
      "address" => %{"city" => "Amsterdam"}
    })
  end

  defp successful_logs(endpoint \\ "https://api.segment.io/v1/") do
    [
      [
        "[info] [Segment.Analytics.HTTP] POST #{endpoint}",
        ~s({"x-api-key", "[FILTERED]"}])
      ],
      "[info] [Segment.Analytics.HTTP] {",
      "[info] [Segment.Analytics.HTTP] 200",
      ["[info] [Segment.Analytics.HTTP] {", ~s("address":{})]
    ]
  end

  defp failed_logs(reason) do
    api_failed_logs(reason) ++ analytics_failed_logs()
  end

  defp api_failed_logs(reason) do
    [
      [
        "[info] [Segment.Analytics.HTTP] POST https://api.segment.io/v1/",
        ~s({"x-api-key", "[FILTERED]"}])
      ],
      "[info] [Segment.Analytics.HTTP] {",
      "[error] [Segment.Analytics.HTTP] #{reason}"
    ]
  end

  defp analytics_failed_logs,
    do: ["[error] [Segment.Analytics] Segment API request failed"]

  defp retried_successful_logs(amount, reason),
    do: Enum.flat_map(1..amount, fn _index -> api_failed_logs(reason) end) ++ successful_logs()
end
