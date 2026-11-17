#!/bin/sh
set -u
for m in xt_TEE nf_dup_ipv6 nf_dup_ipv4; do
    grep -q "^$m " /proc/modules 2>/dev/null && rmmod "$m" 2>/dev/null
done
exit 0
