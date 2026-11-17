# USB modem (3G/4G)

**Category:** Network  
**Modes:** Router  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Failover or primary WAN over a USB cellular modem.

## How gnuton implements it

Stock `rc` WAN failover + modem helpers.

## Requirements

Stock USB modem support and the modem's serial/PPP drivers in the kernel.

## Franklin approach

Stock handles it; Franklin must not disturb WAN failover ordering.

## Tested / verified

Not tested (no modem available).

## Risks / notes

Driver/modem-specific; Router-mode.

## Why this kind (evidence)

stock: `Advanced_Modem_Content.asp` exists in BOTH rootfs.

## Links / sources

- (none yet)
