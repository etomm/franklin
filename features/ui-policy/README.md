# ui-policy — what Franklin exposes in the UI, and why

A policy is not a fix. This feature collects the **deliberate** deviations from
gnuton's UI for this environment (AiMesh node, `sw_mode=3`, AP mode), keeps them
in one place with their reasons, and makes them reversible.

## Why a feature

Before this, the one policy (unhiding the Traffic Analyzer section) was a `sed`
inside `features/web-ui/build.sh`, mixed with real file fixes. That conflated two
different things:

* *fixes* for vendor files that fail in this environment, and
* *choices* about what the UI should show here.

The second kind belongs to a policy feature: it needs its own dependencies
(`web-ui`, `web-ui-overlay`), its own description, and an off switch.

## How it works

```
features/ui-policy/
  feature.yaml          requires: [web-ui, web-ui-overlay]
  payload/policy.sh     the list: each entry = reason + reversible edit
  payload/start.sh      saves /www/require/modules/menuTree.js, applies policy
  payload/stop.sh       restores the saved original
```

It edits the **served** `/www` (the overlaid tree), not the delta on the stick.
That is what makes it portable: it works the same on a Franklin composition or on
an existing gnuton installation, and reverting needs no rebuild.

## Entries

| policy | why |
|---|---|
| expose the Traffic Analyzer section in AP mode | gnuton's menuTree hides it whenever `sw_mode=3`, but the tabs inside (realtime / 24h / daily / monthly) exist and can be fed on a node |

## Boundaries

- If a page has no data producer, exposing it only shows empty graphs. The
  producer is a separate feature (`traffic-monitor`), and this policy is not a
  substitute for it.
- Anything that repairs a genuinely broken vendor file (missing handler, bad
  ASP) is **not** a policy. Those belong to the httpd/shim work described in
  `docs/feature-alignment.md`.
