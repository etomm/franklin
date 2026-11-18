# snmp

The gnuton SNMP agent, running on stock firmware.

## Why a feature is needed

gnuton ships two halves that stock lacks:

* `usr/sbin/snmpd` (net-snmp 5.9) and its libraries, and
* `Advanced_SNMP_Content.asp`, the configuration page.

Stock has neither, and even with the page present its Apply button would do
nothing: the form posts `action_script=restart_snmpd`, and stock `rc` has no
such action (`strings rc` shows `snmpd_enable` only in the firewall rules).

## What this feature does

```
build.sh             stages gnuton snmpd + libnetsnmp{,-agent,-helpers,-mibs}.so.35
payload/lib.sh       config writer + shared helpers
payload/start.sh     (re)write /tmp/snmpd.conf from nvram, (re)start snmpd, add cron
payload/watch.sh     per-minute: apply changed settings, restart a dead agent
payload/stop.sh      stop agent + cron, leave config/nvram alone
```

`start.sh` also recreates the `.so.35` SONAME links: the build ships only the
real `.35.0.0` files (symlinks do not survive composition), and the loader looks
up the SONAME.

## Configuration

The config is generated exactly the way gnuton's `rc` does it (recovered from
the binary), from the same nvram variables the page writes:

| nvram | effect |
|---|---|
| `snmpd_enable` | 1 starts the agent, 0 stops it (watcher stays scheduled) |
| `roCommunity` / `rwCommunity` | communities, default `public` / `private` |
| `sysName` / `sysLocation` / `sysContact` | MIB-II system group |
| `v3_auth_type` (NONE/MD5/SHA), `v3_auth_passwd` | SNMPv3 auth |
| `v3_priv_type` (NONE/DES/AES), `v3_priv_passwd` | SNMPv3 privacy |

The SNMPv3 user is the router's `http_username`. Generated file is
`/tmp/snmpd.conf` (mode 600), log at `/tmp/snmpd.log`.

## Applying changes

The stock Apply button writes nvram but cannot restart the daemon, so
`watch.sh` runs every minute and compares a hash of the settings. Changes land
within a minute, a disabled agent still starts when switched on, and a crashed
agent is restarted.

## AP mode

SNMP is a local daemon; nothing here needs WAN, routing or firewall state.
`snmpd_wan` (allow queries from WAN) only matters on a router-mode firewall and
is ignored here.

## Verify by hand

```sh
/bin/sh /tmp/mnt/FRANKLIN/franklin/features/snmp/start.sh
pidof snmpd
netstat -lnup | grep 161
cat /tmp/snmpd.conf
```

Then from a workstation (v2c, community `public`):

```sh
snmpget -v2c -c public 192.168.0.4 1.3.6.1.2.1.1.1.0 1.3.6.1.2.1.1.5.0
```

Expected: `Linux ZenWiFi 4.19.183 ... armv7l` and the configured name.
