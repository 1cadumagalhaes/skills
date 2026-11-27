# backend / prompt-3

## Must decide
- Audit of existing code, so it chains to the leaf `~/.agents/skills/code-audit/SKILL.md`; the backend rules supply the invariant (tenant scope inside the query), not the report format.
- Severity by reachable impact: a handler returning another tenant rows is a cross-tenant leak, not a style issue.
- Scope is the 12 handlers plus the queries/repos they reach, not the whole service.

## Must show
- chained: `~/.agents/skills/code-audit/SKILL.md` with the closed file list and a ranked report.
- Per finding: `file:line`, the query missing the tenant predicate, and the smallest fix (push `tenant_id` into the SQL).
- The traversal that proves coverage: every path from each handler to a SQL string, including joins and `fmt.Sprintf` queries.
- A failing test that shows tenant B reading tenant A invoice before the fix.

## Miss if
- Reports route-level auth looks fine without reading the SQL.
- Rewrites the handlers instead of the minimal query fix.
- Skips list/aggregate endpoints, where the predicate is most often dropped.
