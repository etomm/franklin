# System log / remote syslog

**Category:** Monitoring  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Local and remote logging of kernel and daemon messages.

## How gnuton implements it

Stock `syslogd`/`klogd` + `logread`; remote server config on the Log page.

## Requirements

`syslogd`/`klogd` (stock), USB for persistence.

## Franklin approach

Stock logging; forward to a remote collector and persist logs to USB from the boot hook if wanted.

## Tested / verified

`logread`/`dmesg` available; log persistence not configured yet.

## Risks / notes

Flash wear if logs are written to JFFS; prefer USB.

## Why this kind (evidence)

stock: `sbin/syslogd` and `Main_LogStatus_Content.asp` exist in both rootfs.

## Links / sources

- (none yet)
