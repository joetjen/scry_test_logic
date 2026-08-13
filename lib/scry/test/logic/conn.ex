defmodule Scry.Test.Logic.Conn do
  @moduledoc """
  One constructor, `family_tree/0`, returning a ready `conn` prefilled
  with `Scry.Test.Logic.Seed`'s own clauses -- straight into `Scry.
  Logic.Executor.run/3`'s own second argument.

  Unlike `Scry.Test.Core.Conn`/`Scry.Test.TimeSeries.Conn` (one
  constructor *per* interchangeable `Scry.Core.EngineBehaviour`
  backend), there's only ever one constructor here, and no bespoke
  struct either: `scry_logic` has exactly one executor (`Scry.Logic.
  Executor`, implementing `EngineBehaviour` directly against a plain
  `%{{name, arity} => [clause_fun]}` map), not a family of
  interchangeable pushdown engines to parity-test against. This
  package's own value is a shared, realistic fixture -- reusable by
  anything depending on `scry_logic` -- and `config/config.exs`, wiring
  `scry_core`'s own generic `mix scry.query`/`mix scry.iex` to use it
  for ad-hoc exploration.
  """

  @doc "`Scry.Test.Logic.Seed.family_tree/0`'s own dataset, unwrapped -- already the exact conn shape `Scry.Logic.Executor.run/3` expects."
  @spec family_tree() :: %{
          {String.t(), non_neg_integer()} => [([term()] -> Ichor.Backtrack.goal())]
        }
  def family_tree, do: Scry.Test.Logic.Seed.family_tree()
end
