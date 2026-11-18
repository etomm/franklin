#!/bin/sh
# Shared settings for the SNMP feature. Sourced, not executed.

SNMP_NVRAM="snmpd_enable roCommunity rwCommunity sysName sysLocation sysContact
            v3_auth_type v3_auth_passwd v3_priv_type v3_priv_passwd"

# Hash of everything that ends up in snmpd.conf, plus the enable flag. Used to
# notice a change made in the UI (stock apply.cgi writes the nvram variables,
# but stock rc has no restart_snmpd action to act on them).
snmp_settings_hash() {
    for v in $SNMP_NVRAM; do
        printf '%s=%s\n' "$v" "$(nvram get "$v" 2>/dev/null)"
    done | sha256sum | cut -d' ' -f1
}

snmp_enabled() {
    [ "$(nvram get snmpd_enable 2>/dev/null)" = "1" ]
}

snmp_running() {
    [ -n "$(pidof snmpd 2>/dev/null)" ]
}

# The loader needs the SONAME names; the build only ships real .35.0.0 files.
snmp_link_libs() {
    libdir="$1"
    for lib in libnetsnmp libnetsnmpagent libnetsnmphelpers libnetsnmpmibs; do
        [ -f "$libdir/$lib.so.35.0.0" ] || continue
        [ -e "$libdir/$lib.so.35" ] || ln -s "$lib.so.35.0.0" "$libdir/$lib.so.35" 2>/dev/null
    done
}

# Write /tmp/snmpd.conf with the rules gnuton's rc uses (recovered from the
# gnuton rc binary: agentAddress, createUser/rwuser for the admin user,
# ro/rw communities, sysName/sysLocation/sysContact).
snmp_write_conf() {
    conf="$1"
    user=$(nvram get http_username 2>/dev/null)
    [ -n "$user" ] || user=admin
    auth_type=$(nvram get v3_auth_type 2>/dev/null)
    case "$auth_type" in
        MD5|SHA) ;;
        *) auth_type=NONE ;;
    esac
    priv_type=$(nvram get v3_priv_type 2>/dev/null)
    case "$priv_type" in
        AES|DES) ;;
        *) priv_type=NONE ;;
    esac
    auth_pass=$(nvram get v3_auth_passwd 2>/dev/null)
    priv_pass=$(nvram get v3_priv_passwd 2>/dev/null)
    ro=$(nvram get roCommunity 2>/dev/null)
    [ -n "$ro" ] || ro=public
    rw=$(nvram get rwCommunity 2>/dev/null)
    [ -n "$rw" ] || rw=private
    sysname=$(nvram get sysName 2>/dev/null)
    [ -n "$sysname" ] || sysname=$(nvram get lan_hostname 2>/dev/null)
    [ -n "$sysname" ] || sysname=$(nvram get productid 2>/dev/null)
    sysloc=$(nvram get sysLocation 2>/dev/null)
    syscontact=$(nvram get sysContact 2>/dev/null)

    {
        echo "agentAddress  udp:161"
        if [ "$priv_type" != "NONE" ]; then
            echo "createUser $user $auth_type $auth_pass $priv_type $priv_pass"
            echo "rwuser $user priv"
        elif [ "$auth_type" != "NONE" ]; then
            echo "createUser $user $auth_type $auth_pass"
            echo "rwuser $user auth"
        else
            echo "createUser $user"
            echo "rwuser $user noauth"
        fi
        [ -n "$ro" ] && echo "rocommunity $ro default"
        [ -n "$rw" ] && echo "rwcommunity $rw default"
        [ -n "$sysname" ] && echo "sysName $sysname"
        [ -n "$sysloc" ] && echo "sysLocation $sysloc"
        [ -n "$syscontact" ] && echo "sysContact $syscontact"
    } >"$conf"
    chmod 600 "$conf" 2>/dev/null
}
