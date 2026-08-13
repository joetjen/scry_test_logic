defmodule Mix.Tasks.Scry.QueryConfigTest do
  @moduledoc """
  `mix scry.query`/`mix scry.iex` themselves live in `scry_core` (a
  generic, config-driven pair -- see that package's own `Scry.Core.
  QueryTool` moduledoc) and are already fully tested there. This is
  just a smoke test that THIS package's own `config/config.exs` wires
  them correctly end to end -- `Scry.Logic.parse/1` as the parser,
  `Scry.Test.Logic.Adapter` bridging `Scry.Logic.Executor`'s own
  `(query, conn, params)` shape to the `(query, engine, conn)` one
  `Scry.Core.QueryTool` expects, and `Scry.Test.Logic.Conn.family_tree/0`
  as the sole named backend.
  """

  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "a goal-shaped query runs correctly through the configured backend" do
    output =
      capture_io(fn ->
        Mix.Tasks.Scry.Query.run(["SELECT parent(\"bob\", Y) { Y }"])
      end)

    assert output =~ ~s("Y" => "ann")
    assert output =~ ~s("Y" => "pat")
  end

  test "the sole configured backend is used implicitly, with no --backend flag needed" do
    output = capture_io(fn -> Mix.Tasks.Scry.Query.run(["SELECT parent(X, Y) { X, Y }"]) end)
    assert output =~ ~s("X" => "tom")
  end
end
