defmodule Segment.Analytics do
  alias Segment.Analytics.Context
  alias Segment.Analytics.Http

  require Logger

  # TODO: should be replaced by an actual batching/buffering logic.
  def batch_track(events) when is_list(events) do
    %Segment.Analytics.BatchTrack{
      batch: Enum.map(events, fn e -> valid_track_event(e) end)
    }
    |> call
  end

  defp valid_track_event(t = %Segment.Analytics.Track{}), do: t

  def track(t = %Segment.Analytics.Track{}), do: call(t)

  def track(user_id, event, properties \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Track{
      userId: user_id,
      event: event,
      properties: properties,
      context: context
    }
    |> call
  end

  def identify(i = %Segment.Analytics.Identify{}), do: call(i)

  def identify(user_id, traits \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Identify{
      userId: user_id,
      traits: traits,
      context: context
    }
    |> call
  end

  def screen(s = %Segment.Analytics.Screen{}), do: call(s)

  def screen(user_id, name \\ "", properties \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Screen{
      userId: user_id,
      name: name,
      properties: properties,
      context: context
    }
    |> call
  end

  def alias(a = %Segment.Analytics.Alias{}), do: call(a)

  def alias(user_id, previous_id, context \\ %Context{}) do
    %Segment.Analytics.Alias{
      userId: user_id,
      previousId: previous_id,
      context: context
    }
    |> call
  end

  def group(g = %Segment.Analytics.Group{}), do: call(g)

  def group(user_id, group_id, traits \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Group{
      userId: user_id,
      groupId: group_id,
      traits: traits,
      context: context
    }
    |> call
  end

  def page(p = %Segment.Analytics.Page{}), do: call(p)

  def page(user_id, name \\ "", properties \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Page{
      userId: user_id,
      name: name,
      properties: properties,
      context: context
    }
    |> call
  end

  defp call(model) do
    model = fill_default_values(model)

    Task.async(fn -> post_to_segment(model.method, Poison.encode!(model)) end)
  end

  defp fill_default_values(model) do
    model
    |> fill_context()
    |> fill_dates()
  end

  defp fill_context(model) do
    put_in(model.context.library, Segment.Analytics.Context.Library.build())
  end

  defp fill_dates(model) do
    put_in(model.sentAt, :os.system_time(:milli_seconds))
  end

  defp post_to_segment(function, body) do
    # all the requests go to the root url
    Http.post("", body)
    |> log_result(function, body)
  end

  # log success responses
  defp log_result({_, %{status_code: code}}, function, body) when code in 200..299 do
    Logger.debug("Segment #{function} call success: #{code} with body: #{body}")
  end

  # log failed responses
  defp log_result(error, function, body) do
    Logger.debug("Segment #{function} call failed: #{inspect(error)} with body: #{body}")
  end
end
