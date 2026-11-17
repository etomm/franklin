# Entware package ecosystem

**Category:** Packages  
**Modes:** all  
**Status:** `planned`  
**Upstream:** gnuton / Asuswrt-Merlin

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
