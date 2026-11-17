# Feature build scripts

Each feature is **separable**: it can be built/installed on its own, as long as
its declared dependencies (see `docs/features/<id>.md`) are present.

Convention:

```
features/<id>/
  build.sh     # produce artifacts (optional)
  install.sh   # deploy to USB / router (optional)
  readme.md    # feature-specific notes (optional)
```

The planner `tools/franklin-build.py` resolves dependencies and runs
`build.sh` in dependency order:

```
python tools/franklin-build.py --features cake-qos --run
```

Required environment for kernel-feature builds:

- `GPL`   — path to the ASUS GPL zip (matching the device firmware)
- `CONFIG`— device kernel config (`zcat /proc/config.gz > device.config`)

Example:

```
export GPL=/path/GPL_ZENWIFI_XT9_30043882435854.zip
export CONFIG=/path/device.config
python tools/franklin-build.py --features cake-qos,tee,ipset --run
```

Removing a feature is supported: `--without <id>` fails loudly if something
else still depends on it.
