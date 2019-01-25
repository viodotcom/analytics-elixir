defmodule Segment.Analytics.HttpTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "post/4" do
    test "the request sent is correct", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        # We don't care about `request_path` or `method` for this test.
        Plug.Conn.resp(conn, 200, "")
      end)

      Segment.Analytics.Http.post("something", "{}", [])
    end
  end
end
