# SSH access (dropbear / openssh)

**Category:** System  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS (dropbear)

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Remote shell access, key-based logins, and optional full OpenSSH.

## How gnuton implements it

Stock `dropbear` + Merlin tweaks; gnuton adds `scp` only.

## Requirements

`dropbear` (stock), USB or `/jffs` for `authorized_keys`.

## Franklin approach

Stock dropbear + authorized_keys on USB/JFFS; Entware openssh only if sftp/scp is required.

## Tested / verified

dropbear works with key auth from this workstation; no scp/sftp (use `cat >`).

## Risks / notes

Exposing SSH to WAN is unsafe; keys must be deployed before disabling passwords.

## Why this kind (evidence)

stock: `usr/sbin/dropbear` is in both rootfs (gnuton only adds `usr/bin/scp`).

## Links / sources

- `docs/xt9-notes.md`
