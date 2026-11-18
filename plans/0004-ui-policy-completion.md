# 0004 — UI policy completion

**Status:** foundation done (`features/ui-policy/`) · **Fixes:** alignment #3

## Why

The AP-mode menu exposure is a product decision, so it now lives in its own
feature instead of `web-ui/build.sh`. What remains is to make it a complete,
auditable policy: every deviation listed, reversible, and matching an existing
gnuton installation.

## Done

- `features/ui-policy/` applies `menuTree.js` changes at runtime to the served
  tree, keeps a pristine copy in `state/menuTree.js.orig`, restores on stop.
- Requires `web-ui` + `web-ui-overlay`; excluded from the delta.
- Verified on the device: exclusions `5 → 0 → 5 → 0` (pristine, policy, revert,
  policy).

## Remaining steps

1. **Audit other AP-mode decisions** and decide whether each belongs here:
   - Traffic Analyzer section (done);
   - tabs excluded by `menuTree.exclude.tabs()` that work on a node
     (`TrafficAnalyzer_Statistic.asp` stays hidden: no DPI);
   - any page whose data depends on router mode should stay hidden — record it.
2. **Make entries declarative**: extend `payload/policy.sh` to a list with
   `policy_<name>() { reason; apply; verify; }` and have `start.sh` iterate, so
   the README table can be generated from the file instead of maintained twice.
3. **Interaction with third-party installers**: `wifi-insight`'s addon edits the
   same `menuTree.js`. Define ordering (policy after addon install) and make
   `stop.sh` restore the pristine copy only if no later installer edited it
   (compare a hash and warn instead of clobbering).
4. **Document it as an installation-agnostic feature**: it patches the served
   tree, so it also applies to a plain gnuton install on this model. Say so in
   `feature.yaml` notes and the catalog entry (already partially there).
5. **Test the revert path after a reboot** (state file survives; verify).

## Acceptance

- `start.sh` output lists every applied policy; `stop.sh` returns the file to
  the exact pre-policy content (`cmp` against the saved copy).
- No policy lives in `web-ui/build.sh`.
- README's table matches `policy.sh` (or is generated from it).
- Reboot with the feature enabled leaves the UI exposed and the backup present.

## Rollback

`stop.sh` restores the pristine `menuTree.js`; disabling the feature in
`franklin.yaml` removes the policy entirely.

## Files

`features/ui-policy/*`, `features/wifi-insight/payload/start.sh` (ordering /
hash check), `tools/feature-catalog.py`.
