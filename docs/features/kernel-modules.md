# Kernel modules (build recipe)

**Category:** Kernel  
**Modes:** all  
**Status:** `tested`  
**Kind:** franklin-feature  
**Required:** no  
**Upstream:** ASUS GPL 4.19.183 (not gnuton)

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Run features/kernel-modules/build.sh (calls tools/build-kernel-modules.sh with the ASUS GPL + device config).

## What it does

Add absent kernel features as `.ko` (Cake, TEE, ipset, ...).

## How gnuton implements it

Ships modules built for its kernel.

## Requirements

ASUS GPL tree (matching version), device `/proc/config.gz`, cross toolchain, `MODEL=XT9`.

## Franklin approach

Build from ASUS GPL + bcmkernel include path; load from boot hook.

## Tested / verified

Cake, TEE, nf_dup, ipset built+loaded+functionally verified.

## Risks / notes

Must match kernel 4.19.183 + config; not vanilla.

## Links / sources

- `docs/xt9-kernel-notes.md`
- `docs/kernel-feature-matrix.md`
