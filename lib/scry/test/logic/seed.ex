defmodule Scry.Test.Logic.Seed do
  @moduledoc """
  A small family-tree clause database, shaped after the worked example
  domain (`ancestor`/`parent`/`age`, "bob" included)
  -- `parent/2` and `age/2` are ground facts; `ancestor/2` is the one
  genuinely recursive relation, written the correct (lazy-wrapped) way
  `Scry.Logic.Executor`'s own moduledoc documents as load-bearing, not
  stylistic -- any other shape hangs forever building the goal.

  ```
  tom -> bob -> ann
              -> pat
  ```

  Deliberately includes a leaf with no descendants (`ann`, `pat`) and an
  age spread crossing common comparison thresholds (8, 10, 35, 60), so
  a query combining the recursive relation with a `WHERE`-embedded goal
  call (`age(X) > 30`) has real
  negative cases to exclude, not just positive ones to find.
  """

  alias Ichor.Backtrack.{Bindings, Tree}
  alias Scry.Logic.Term

  @doc "A goal that unifies `t1` and `t2` -- `Ichor`'s own `Prolog.DB.eq/2` worked example, verbatim."
  def eq(t1, t2) do
    fn bindings ->
      case Bindings.unify(Term, bindings, t1, t2) do
        {:ok, extended} -> Tree.unit().(extended)
        :fail -> Tree.fail().(bindings)
      end
    end
  end

  @doc "Unifies every `{t1, t2}` pair in order, short-circuiting on the first failure."
  def unify_all(pairs) do
    Enum.reduce(pairs, Tree.unit(), fn {t1, t2}, acc -> Tree.conjunction(acc, eq(t1, t2)) end)
  end

  @doc "Tries every clause (in order) against `args`, as a disjunction."
  def solve_any(clauses, args) do
    Enum.reduce(clauses, Tree.fail(), fn clause, acc -> Tree.disjunction(acc, clause.(args)) end)
  end

  @doc "parent(tom, bob). parent(bob, ann). parent(bob, pat)."
  def parent_clauses do
    [
      fn [x, y] -> unify_all([{x, "tom"}, {y, "bob"}]) end,
      fn [x, y] -> unify_all([{x, "bob"}, {y, "ann"}]) end,
      fn [x, y] -> unify_all([{x, "bob"}, {y, "pat"}]) end
    ]
  end

  @doc "The `parent/2` goal itself -- `solve_any(parent_clauses(), args)`, the shape `family_tree/0`'s own `conn` map calls by name."
  def parent(args), do: solve_any(parent_clauses(), args)

  @doc "age(tom, 60). age(bob, 35). age(ann, 10). age(pat, 8)."
  def age_clauses do
    [
      fn [x, y] -> unify_all([{x, "tom"}, {y, 60}]) end,
      fn [x, y] -> unify_all([{x, "bob"}, {y, 35}]) end,
      fn [x, y] -> unify_all([{x, "ann"}, {y, 10}]) end,
      fn [x, y] -> unify_all([{x, "pat"}, {y, 8}]) end
    ]
  end

  @doc "The `age/2` goal itself -- `solve_any(age_clauses(), args)`, the shape `family_tree/0`'s own `conn` map calls by name."
  def age(args), do: solve_any(age_clauses(), args)

  @doc """
  `ancestor(X, Y) :- parent(X, Y).`
  `ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).`

  The recursive second clause wraps its own self-call in
  `fn bindings -> ancestor([z, y]).(bindings) end` -- required, not a
  style choice; see `Scry.Logic.Executor`'s own moduledoc.
  """
  def ancestor_clauses do
    [
      fn [x, y] -> parent([x, y]) end,
      fn [x, y] ->
        z = {:var, make_ref()}
        Tree.conjunction(parent([x, z]), fn bindings -> ancestor([z, y]).(bindings) end)
      end
    ]
  end

  @doc "The `ancestor/2` goal itself -- `solve_any(ancestor_clauses(), args)`, the shape `family_tree/0`'s own `conn` map calls by name."
  def ancestor(args), do: solve_any(ancestor_clauses(), args)

  @doc "The `Scry.Logic.Executor.run/3` `conn` shape -- a plain `%{{name, arity} => [clause_fun]}` map."
  @spec family_tree() :: %{
          {String.t(), non_neg_integer()} => [([term()] -> Ichor.Backtrack.goal())]
        }
  def family_tree do
    %{
      {"parent", 2} => parent_clauses(),
      {"age", 2} => age_clauses(),
      {"ancestor", 2} => ancestor_clauses()
    }
  end
end
