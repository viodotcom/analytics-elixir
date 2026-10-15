defmodule Segment.Analytics.Batch do
  @derive [Jason.Encoder]

  defstruct [
    :batch,
    :sentAt
  ]
end

defmodule Segment.Analytics.Track do
  @derive [Jason.Encoder]
  @method "track"

  defstruct [
    :anonymousId,
    :context,
    :event,
    :messageId,
    :properties,
    :timestamp,
    :userId,
    :version,
    type: @method
  ]
end

defmodule Segment.Analytics.Identify do
  @derive [Jason.Encoder]
  @method "identify"

  defstruct [
    :anonymousId,
    :context,
    :messageId,
    :timestamp,
    :traits,
    :userId,
    :version,
    type: @method
  ]
end

defmodule Segment.Analytics.Alias do
  @derive [Jason.Encoder]
  @method "alias"

  defstruct [:context, :previousId, :timestamp, :userId, :version, type: @method]
end

defmodule Segment.Analytics.Page do
  @derive [Jason.Encoder]
  @method "page"

  defstruct [
    :anonymousId,
    :context,
    :messageId,
    :name,
    :properties,
    :timestamp,
    :userId,
    :version,
    type: @method
  ]
end

defmodule Segment.Analytics.Screen do
  @derive [Jason.Encoder]
  @method "screen"

  defstruct [
    :anonymousId,
    :context,
    :messageId,
    :name,
    :properties,
    :timestamp,
    :userId,
    :version,
    type: @method
  ]
end

defmodule Segment.Analytics.Group do
  @derive [Jason.Encoder]
  @method "group"

  defstruct [
    :anonymousId,
    :context,
    :groupId,
    :messageId,
    :timestamp,
    :traits,
    :userId,
    :version,
    type: @method
  ]
end

defmodule Segment.Analytics.Context.Library do
  @derive [Jason.Encoder]

  @project_name Mix.Project.get().project[:name]
  @project_version Mix.Project.get().project[:version]

  defstruct [:name, :version, :transport]

  def build() do
    %__MODULE__{
      name: @project_name,
      version: @project_version,
      # the only supported by the library for now.
      transport: "http"
    }
  end
end

defmodule Segment.Analytics.Context do
  @derive [Jason.Encoder]

  defstruct [
    :app,
    :ip,
    :library,
    :location,
    :os,
    :page,
    :referrer,
    :screen,
    :timezone,
    :traits,
    :userAgent
  ]
end
