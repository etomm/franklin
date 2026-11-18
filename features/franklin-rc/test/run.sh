#!/bin/sh
# Host-side test of the shim's dispatch logic. No router involved: a fake
# "libshared" records what would have reached stock rc, and the companion
# records what the shim handed to it. Checks both directions and all the
# notify_rc variants httpd can call.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
rc_dir=$(cd "$here/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

# 1. the real notify_rc family, standing in for libshared
cc -shared -fPIC -O2 -o "$tmp/libreal.so" "$here/fake_provider.c"

# 2. a caller that only knows the notify_rc family (like httpd)
cc -O2 -o "$tmp/caller" "$here/caller.c" -L"$tmp" -lreal -Wl,-rpath,"$tmp"

# 3. the generated action table, exactly as build.sh makes it
{
    echo "/* generated */"
    echo "static const char *const franklin_actions[] = {"
    for a in $(cd "$rc_dir/actions" && ls -1 *.sh | sed 's/\.sh$//'); do
        echo "    \"$a\","
    done
    echo "    NULL"
    echo "};"
} >"$tmp/actions.h"

# 4. the shim, with the same sources the router gets
cc -shared -fPIC -O2 -Wall -Wextra -Werror -I"$tmp" \
    -o "$tmp/libshim.so" "$rc_dir/src/shim.c" -ldl

# 5. companion stub that records the action it was given
cat >"$tmp/franklin-rc" <<'EOF'
#!/bin/sh
printf '%s\n' "$1" >>"$COMPANION_LOG"
EOF
chmod 755 "$tmp/franklin-rc"

run() {  # run <variant> <action> [<second action>]
    PROVIDER_LOG="$tmp/provider.log" COMPANION_LOG="$tmp/companion.log" \
    FRANKLIN_RC="$tmp/franklin-rc" \
    LD_PRELOAD="$tmp/libshim.so" "$tmp/caller" "$@"
    # fire-and-forget child
    sleep 1
}

status=0
expect() {  # expect <file> <expected>
    got=$(cat "$1" 2>/dev/null)
    if [ "$got" = "$2" ]; then
        echo "ok: $(basename "$1"): $(printf '%s' "$got" | tr '\n' ' ')"
    else
        echo "FAIL: $(basename "$1") expected '$2', got '$got'"
        status=1
    fi
}

# plain notify_rc: ours diverted, theirs forwarded
run plain restart_snmpd restart_wireless
expect "$tmp/companion.log" "restart_snmpd"
expect "$tmp/provider.log" "notify_rc restart_wireless"

# _and_wait variant: also diverted
: >"$tmp/companion.log"; : >"$tmp/provider.log"
run and_wait restart_snmpd
expect "$tmp/companion.log" "restart_snmpd"
expect "$tmp/provider.log" ""

# _period_wait variant: forwarded with its extra argument intact
: >"$tmp/companion.log"; : >"$tmp/provider.log"
run period restart_wireless
expect "$tmp/companion.log" ""
expect "$tmp/provider.log" "notify_rc_after_period_wait restart_wireless"

# unknown action through _after_wait: forwarded
: >"$tmp/companion.log"; : >"$tmp/provider.log"
run after_wait restart_wireless
expect "$tmp/provider.log" "notify_rc_after_wait restart_wireless"

exit $status
