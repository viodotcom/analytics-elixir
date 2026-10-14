defmodule Segment.Analytics.Context.LibraryTest do
  use ExUnit.Case, async: true

  alias Segment.Analytics.Context.Library

  describe "build/1" do
    test "builds the library struct with the default values" do
      assert %Library{
               name: Mix.Project.get().project[:name],
               transport: "http",
               version: Mix.Project.get().project[:version]
             } == Library.build()
    end
  end
end

defmodule Segment.Analytics.TrackTest do
  use ExUnit.Case, async: true

  describe "encoding" do
    test "encodes analytics models with Jason" do
      assert %{"event" => "signup", "type" => "track"} =
               %Segment.Analytics.Track{event: "signup"}
               |> Jason.encode!()
               |> Jason.decode!()
               |> Map.take(["event", "type"])
    end
  end
end
