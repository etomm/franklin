# Plans

Actionable work items, one file each. A plan is done only when its **Acceptance**
section passes on the device and the `Rollback` steps are known.

| plan | status | depends on | fixes |
|---|---|---|---|
| [0001 traffic history from rstats](0001-traffic-history-rstats.md) | ready | — | alignment #5 (page takeover) |
| [0002 choose the httpd variant](0002-httpd-variant-selection.md) | **parked** (CI recipe inside) | GitHub CI or a disk with ~40 GB | alignment #1/#2, unblocks 0003 |
| [0003 WiFi Insight from vendor sources](0003-wifi-insight-visgui.md) | blocked | 0002 (variant E) | alignment #4 |
| [0004 UI policy completion](0004-ui-policy-completion.md) | partially done | — | alignment #3 |

Completed and folded into the tree: library override policy
(`docs/library-overrides.md`, `tools/lib-audit.sh`) and the `ui-policy` feature
foundation.

Conventions:

- every plan lists **Why**, **Steps** (runnable), **Acceptance** (observable),
  **Rollback**, and the files it touches;
- device experiments run on a throwaway port (`:8089`), never on `:80`
  (`AGENTS.md` rule 3);
- if a step changes persisted state, say how it is restored.
