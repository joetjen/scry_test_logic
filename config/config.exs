import Config

# Wires this package's own single Scry.Test.Logic.Conn.family_tree/0
# fixture into scry_core's generic mix scry.query/mix scry.iex -- see
# Scry.Core.QueryTool's own moduledoc for the full config shape.
# parser: points at Scry.Logic.parse/1, since this package exercises
# the logic kind, not core's own degenerate one. executor: is Scry.
# Test.Logic.Adapter, not Scry.Logic.Executor directly -- the adapter
# bridges QueryTool's own (query, engine, conn) calling convention to
# Scry.Logic.Executor's (query, conn, params) shape (that module's own
# moduledoc has the full "why" -- scry_logic has no separate "engine"
# concept at all).
config :scry_core, :query_tool,
  parser: Scry.Logic,
  executor: {Scry.Test.Logic.Adapter, :run},
  backends: %{
    "logic" => {Scry.Test.Logic.Adapter, :conn}
  }
