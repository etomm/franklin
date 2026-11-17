# Entware package ecosystem

**Category:** Packages  
**Modes:** all  
**Status:** `planned`  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Install Entware on USB (armv7sf-k3.2).

## What it does

opkg package manager with thousands of binaries.

## How gnuton implements it

Not bundled; users install Entware on USB.

## Requirements

USB (not JFFS), `armv7sf-k3.2` repo.

## Franklin approach

Install Entware on USB; unset LD_LIBRARY_PATH for its binaries.

## Tested / verified

Not yet installed.

## Risks / notes

glibc conflicts; use unset LD_LIBRARY_PATH.

## Links / sources

- (none yet)
