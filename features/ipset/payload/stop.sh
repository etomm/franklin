#!/bin/sh
set -u
rm -f /tmp/ipset 2>/dev/null
for m in ip_set_hash_ip ip_set; do
    grep -q "^$m " /proc/modules 2>/dev/null && rmmod "$m" 2>/dev/null
done
exit 0
