# Changelog

## [Unreleased]

### Added

- Shared test fixtures for `scry_logic` -- `Scry.Test.Logic.Seed`/`.Conn`'s own `family_tree/0`, a small `parent`/`age`/`ancestor` clause database shaped after lang_spec.md §8.4's own worked example domain (tom -> bob -> {ann, pat}), in the exact `%{{name, arity} => [clause_fun]}` shape `Scry.Logic.Executor.run/3` expects. `ancestor/2` is the one genuinely recursive relation, written the correct (lazy-wrapped self-call) way `Scry.Logic.Executor`'s own moduledoc documents as load-bearing.
  `Scry.Test.Logic.Adapter` bridges `Scry.Core.QueryTool`'s own `(query, engine, conn)` calling convention to `Scry.Logic.Executor.run/3`'s `(query, conn, params)` shape, the same pattern `scry_test_search`/`scry_test_graph`/`scry_test_document` already established; `config/config.exs` wires it into `scry_core`'s generic `mix scry.query`/`mix scry.iex` as the sole named backend.
  A single-constructor fixture package, the same narrower `scry_test_<kind>` variant `scry_test_search` already is -- `scry_logic` has exactly one executor, no interchangeable `Scry.Core.EngineBehaviour` backends to prove parity across.
  `test/scry/test/logic/conn_test.exs` (including the lang_spec.md §8.4 worked example running end to end against this fixture), `test/mix/tasks/scry.query_test.exs`.
