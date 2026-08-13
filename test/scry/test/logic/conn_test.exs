defmodule Scry.Test.Logic.ConnTest do
  @moduledoc """
  `Scry.Test.Logic.Conn.family_tree/0` -- confirms it returns a real,
  working `conn` (prefilled with `Scry.Test.Logic.Seed`'s own dataset),
  actually executing the lang_spec.md §8.4 worked example correctly
  through `Scry.Logic.Executor.run/3`.
  """

  use ExUnit.Case, async: true

  alias Scry.Core.Cursor
  alias Scry.Logic.Executor
  alias Scry.Test.Logic.Conn

  defp run!(source) do
    {:ok, query} = Scry.Logic.parse(source)
    {:ok, cursor} = Executor.run(query, Conn.family_tree())
    Cursor.to_list(cursor)
  end

  test "an unbound goal returns every parent fact, in declared order" do
    assert run!("SELECT parent(X, Y) { X, Y }") == [
             %{"X" => "tom", "Y" => "bob"},
             %{"X" => "bob", "Y" => "ann"},
             %{"X" => "bob", "Y" => "pat"}
           ]
  end

  test "the lang_spec.md §8.4 worked example runs correctly against this fixture" do
    rows = run!("SELECT ancestor(X, \"bob\") WHERE age(X) > 30 { X }")

    # tom (60) is bob's own parent and satisfies age > 30; bob himself
    # is never his own ancestor, and neither ann nor pat is an ancestor
    # of bob at all (they're his children).
    assert rows == [%{"X" => "tom"}]
  end

  test "recursion terminates and finds every transitive descendant" do
    assert run!("SELECT ancestor(\"tom\", Y) { Y }") == [
             %{"Y" => "bob"},
             %{"Y" => "ann"},
             %{"Y" => "pat"}
           ]
  end

  test "calling family_tree/0 twice returns independently-seeded conns with identical data" do
    assert Conn.family_tree() == Conn.family_tree()
  end
end
