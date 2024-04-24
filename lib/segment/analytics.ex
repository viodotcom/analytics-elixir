defmodule Segment.Analytics do
  @moduledoc """
  Performs requests to Segment API.
  """

  require Logger

  alias Segment.Analytics.Batch
  alias Segment.Analytics.Context
  alias Segment.Analytics.HTTP
  alias Segment.Config
  alias Segment.Encoder

  def track(t = %Segment.Analytics.Track{}), do: call(t)

  def track(user_id, event, properties \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Track{
      userId: user_id,
      event: event,
      properties: properties,
      context: context
    }
    |> call()
  end

  def identify(i = %Segment.Analytics.Identify{}), do: call(i)

  def identify(user_id, traits \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Identify{
      userId: user_id,
      traits: traits,
      context: context
    }
    |> call()
  end

  def screen(s = %Segment.Analytics.Screen{}), do: call(s)

  def screen(user_id, name \\ "", properties \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Screen{
      userId: user_id,
      name: name,
      properties: properties,
      context: context
    }
    |> call()
  end

  def alias(a = %Segment.Analytics.Alias{}), do: call(a)

  def alias(user_id, previous_id, context \\ %Context{}) do
    %Segment.Analytics.Alias{
      userId: user_id,
      previousId: previous_id,
      context: context
    }
    |> call()
  end

  def group(g = %Segment.Analytics.Group{}), do: call(g)

  def group(user_id, group_id, traits \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Group{
      userId: user_id,
      groupId: group_id,
      traits: traits,
      context: context
    }
    |> call()
  end

  def page(p = %Segment.Analytics.Page{}), do: call(p)

  def page(user_id, name \\ "", properties \\ %{}, context \\ %Context{}) do
    %Segment.Analytics.Page{
      userId: user_id,
      name: name,
      properties: properties,
      context: context
    }
    |> call()
  end

  @doc """
  Returns a `Task` that must be awaited on that merges the options received with the application
  environment and sends the payload to the Segment API.

  The task returns `{:ok, binary}` with the raw response body if the request succeeded with
  valid result.

  On failure, the task returns `{:error, binary}` with either the raw response body if the
  request succeded or the inspected error otherwise.

  For options documentation, see `t:Segment.options/0`.

  ## Examples

      iex> model = %Segment.Analytics.Page{...}
      ...> #{inspect(__MODULE__)}.call(model)
      %Task{...}

      ...> #{inspect(__MODULE__)}.call(model, max_retries: 2)
      %Task{...}

  """
  @spec call(Segment.model(), Segment.options()) :: Task.t()
  def call(model, options \\ []) do
    Task.async(fn ->
      %Config{} = config = Config.get(options)

      model
      |> generate_message_id()
      |> fill_context()
      |> wrap_in_batch()
      |> Encoder.encode!(config)
      |> post_to_segment(config)
    end)
  end

  defp generate_message_id(model), do: put_in(model.messageId, UUID.uuid4())

  defp fill_context(model),
    do: put_in(model.context.library, Context.Library.build())

  # TODO: replace with an actual buffering
  # to send events in batches rather than one by one
  # The idea is to reduce the traffic to the segment service
  defp wrap_in_batch(model) do
    %Batch{
      batch: [model],
      sentAt: :os.system_time(:milli_seconds)
    }
  end

  @spec post_to_segment(String.t(), Config.t()) :: HTTP.request_result()
  defp post_to_segment(body, %Config{} = config) do
    case HTTP.post(body, config) do
      {:ok, _body} = result ->
        result

      {:error, _reason} = result ->
        log_post_result(:error, "Segment API request failed", config)
        result
    end
  end

  @spec log_post_result(Logger.level(), String.t(), Config.t()) :: :ok
  defp log_post_result(log_level, message, %Config{} = config),
    do: Logger.log(log_level, "[#{config.prefix}] #{message}")
end
