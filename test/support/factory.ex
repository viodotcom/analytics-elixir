defmodule Segment.Support.Factory do
  alias Segment.Analytics.{Batch, Context, Track}

  defmodule Properties do
    defstruct ~w(
        foo
        bar
        baz
        decimal
        date
        datetime
        qux
        corge
        grault
        garply
        waldo
      )a
  end

  defmodule NestedProperties do
    defstruct ~w(foo bar baz qux)a
  end

  def build(:batch) do
    %Batch{
      batch: [
        %Track{
          context: %Context{app: %{name: "analytics_elixir", version: "1.0.0"}},
          messageId: "e66f98cf-3a99-4895-a0a3-d5e6f72eeb23",
          properties: %Properties{
            bar: 2.5,
            baz: "baz",
            corge: [
              %{bar: 2.5, baz: "baz", foo: 1, qux: nil},
              %{}
            ],
            foo: 1,
            garply: %{foo: 1, bar: 2.5, baz: "baz", qux: nil},
            grault: [
              %NestedProperties{bar: 2.5, baz: "baz", foo: 1, qux: nil},
              %NestedProperties{}
            ],
            decimal: Decimal.new("123.33"),
            date: ~D[2016-05-24],
            datetime: ~U[2016-05-24 13:26:08.003Z],
            qux: nil,
            waldo: %NestedProperties{bar: 2.5, baz: "baz", foo: 1, qux: nil}
          }
        }
      ],
      sentAt: 1_608_657_553_311
    }
  end

  def map_for(:app), do: %{name: "analytics_elixir", version: "1.0.0"}

  def map_for(:batch), do: %{batch: [map_for(:track)], sentAt: 1_608_657_553_311}

  def map_for(:batch_without_null),
    do: %{batch: [map_for(:track_without_null)], sentAt: 1_608_657_553_311}

  def map_for(:context) do
    %{
      app: map_for(:app),
      ip: nil,
      library: nil,
      location: nil,
      os: nil,
      page: nil,
      referrer: nil,
      screen: nil,
      timezone: nil,
      traits: nil,
      userAgent: nil
    }
  end

  def map_for(:context_without_null), do: %{app: map_for(:app)}

  def map_for(:properties) do
    %{
      baz: "baz",
      bar: 2.5,
      corge: [
        %{bar: 2.5, baz: "baz", foo: 1, qux: nil},
        %{}
      ],
      foo: 1,
      garply: %{bar: 2.5, baz: "baz", foo: 1, qux: nil},
      grault: [
        %{bar: 2.5, baz: "baz", foo: 1, qux: nil},
        %{bar: nil, baz: nil, foo: nil, qux: nil}
      ],
      qux: nil,
      decimal: 123.33,
      date: "2016-05-24",
      datetime: "2016-05-24T13:26:08.003Z",
      waldo: %{bar: 2.5, baz: "baz", foo: 1, qux: nil}
    }
  end

  def map_for(:properties_without_null) do
    %{
      baz: "baz",
      bar: 2.5,
      corge: [
        %{bar: 2.5, baz: "baz", foo: 1},
        %{}
      ],
      foo: 1,
      garply: %{bar: 2.5, baz: "baz", foo: 1},
      grault: [
        %{bar: 2.5, baz: "baz", foo: 1},
        %{}
      ],
      decimal: 123.33,
      date: "2016-05-24",
      datetime: "2016-05-24T13:26:08.003Z",
      waldo: %{bar: 2.5, baz: "baz", foo: 1}
    }
  end

  def map_for(:track) do
    %{
      anonymousId: nil,
      context: map_for(:context),
      event: nil,
      messageId: "e66f98cf-3a99-4895-a0a3-d5e6f72eeb23",
      properties: map_for(:properties),
      timestamp: nil,
      type: "track",
      userId: nil,
      version: nil
    }
  end

  def map_for(:track_without_null) do
    %{
      context: map_for(:context_without_null),
      messageId: "e66f98cf-3a99-4895-a0a3-d5e6f72eeb23",
      properties: map_for(:properties_without_null),
      type: "track"
    }
  end

  def string_map_for(key) do
    key
    |> map_for()
    |> Poison.encode!()
    |> Poison.decode!()
  end
end
