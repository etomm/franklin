#!/usr/bin/env python3
"""Keep the parity table honest and machine-checked.

Two jobs:

1. Link every parity row to a real plan in docs/features/ using an EXPLICIT
   row -> plan map (no fuzzy keyword guessing, which linked the wrong plans).
2. Regenerate docs/gnuton-feature-parity.html from the Markdown, so the
   sortable page can never drift from the table again (it previously had no
   links and stale statuses).

It fails loudly when:
  * a parity row has no entry in ROW_PLAN (so new rows cannot be forgotten),
  * a mapped plan file does not exist,
  * a row still carries a stale/different [plan](...) link.

Usage:  python tools/parity-sync.py [--check]
"""
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
DOCS = os.path.join(ROOT, "docs")
MD = os.path.join(DOCS, "gnuton-feature-parity.md")
HTML = os.path.join(DOCS, "gnuton-feature-parity.html")
FEATDIR = os.path.join(DOCS, "features")

# row number -> plan id. Chosen explicitly after auditing stock vs gnuton rootfs
# (see tools/parity-audit.py). A row only points at a gnuton/workaround plan if
# gnuton really provides that feature and stock does not.
ROW_PLAN = {
    1: "vlan-iptv",          # Merlin softswitch/VLAN; stock has no UI
    2: "vlan-iptv",
    3: "boot-hook",          # workaround for /jffs/scripts
    4: "custom-scripts",     # gnuton /jffs/scripts hooks
    5: "jffs",               # stock
    6: "cake-qos",
    7: "igmp-snooping",      # stock/driver-level
    8: "cake-qos",
    9: "cake-qos",
    10: "amtm",              # bundled in gnuton
    11: "cifs-client",       # in neither (franklin addition)
    12: "ddns",
    13: "dhcp-leases",       # stock
    14: "network-tools",
    15: "disk-monitoring",   # Entware (franklin addition)
    16: "disk-spindown",     # stock
    17: "dnsmasq-custom",
    18: "dns-over-tls",
    19: "dns-director",
    20: "download-manager",  # franklin addition (aria2)
    21: "firewall-custom",
    22: "web-ui",
    23: "led-control",
    24: "network-tools",
    25: "nfs",               # gnuton ships nfsd/exportfs
    26: "ntp",               # gnuton ships ntpd
    27: "nvram-tools",
    28: "nvram-tools",
    29: "reboot-schedule",
    30: "snmp",              # gnuton ships snmpd
    31: "ssh-access",        # stock dropbear
    32: "syslog",            # stock
    33: "temperature-monitoring",
    34: "web-ui-overlay",    # workaround
    35: "bridge-management", # stock
    36: "cron",              # gnuton ships crontab
    37: "entware",           # franklin feature
    38: "adaptive-qos",
    39: "aimesh",            # stock
    40: "aiprotection",      # proprietary
    41: "ap-modes",          # stock
    42: "cloud-sync",        # proprietary
    43: "firmware-upgrade",  # stock
    44: "samba-ftp-webdav",  # stock
    45: "guest-network",     # stock
    46: "ipsec-vpn",
    47: "ipv6",              # stock
    48: "mac-filter",        # stock
    49: "media-server",      # stock minidlna
    50: "nat-acceleration",  # stock/firmware
    51: "networkmap",        # gnuton daemon + workaround
    52: "parental-controls", # stock
    53: "port-forwarding",   # stock
    54: "samba-ftp-webdav",
    55: "samba-ftp-webdav",
    56: "time-machine",      # stock
    57: "traffic-analyzer",  # proprietary DPI
    58: "usb-modem",         # stock
    59: "samba-ftp-webdav",
    60: "openvpn-client",
    61: "openvpn-server",
    62: "web-ui",
    63: "samba-ftp-webdav",
    64: "wireguard-client",
    65: "wireless-tuning",   # stock
}

LINK_RE = re.compile(r"\s*\[plan\]\([^)]*\)")
PLAN_LINK = " [plan](features/%s.md)"
BADGE_RANK = {"\u2705": 0, "\U0001f504": 1, "\U0001f4cb": 2, "\u274c": 3,
              "\U0001f3e0": 4, "\U0001f6ab": 5, "\u26d4": 6}


def rows_of(text):
    return [l for l in text.split("\n") if re.match(r"^\|\s*\d+\s*\|", l)]


def split_row(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def link_rows(text, manifest):
    known = {f["id"] for f in manifest["features"]}
    missing = []
    out = []
    seen = set()
    for line in text.split("\n"):
        if not re.match(r"^\|\s*\d+\s*\|", line):
            out.append(line)
            continue
        cols = split_row(line)
        num = int(cols[0])
        seen.add(num)
        pid = ROW_PLAN.get(num)
        if not pid:
            missing.append(num)
            out.append(line)
            continue
        if pid not in known:
            raise SystemExit("row %d maps to unknown plan '%s'" % (num, pid))
        if not os.path.exists(os.path.join(FEATDIR, pid + ".md")):
            raise SystemExit("row %d maps to missing plan file '%s.md'" % (num, pid))
        cols[-1] = LINK_RE.sub("", cols[-1]) + PLAN_LINK % pid
        out.append("| " + " | ".join(cols) + " |")
    if missing:
        raise SystemExit(
            "parity rows without a plan mapping: %s\n"
            "Add them to ROW_PLAN in tools/parity-sync.py (one plan per row)."
            % ", ".join(map(str, missing)))
    unmapped = set(ROW_PLAN) - seen
    if unmapped:
        print("note: ROW_PLAN entries for nonexistent rows: %s" % sorted(unmapped))
    return "\n".join(out)


def md_to_html(md):
    rows = [split_row(l) for l in rows_of(md)]
    head = ("<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n"
            "<title>gnuton / Merlin feature parity (Franklin)</title>\n<style>\n"
            "body { font-family: system-ui, sans-serif; margin: 2rem; }\n"
            "table { border-collapse: collapse; width: 100%; }\n"
            "th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; "
            "vertical-align: top; }\nth { background: #f2f2f2; cursor: pointer; "
            "user-select: none; }\nth:hover { background: #e6e6e6; }\n"
            "tr:nth-child(even) { background: #fafafa; }\n"
            "a { color: #0645ad; }\n</style>\n</head>\n<body>\n"
            "<h1>gnuton / Merlin feature parity (Franklin)</h1>\n"
            "<p>Click a column header to sort. Generated by "
            "<code>tools/parity-sync.py</code> from "
            "<code>docs/gnuton-feature-parity.md</code>.</p>\n"
            "<table id=\"parity\">\n<thead><tr>\n"
            "<th data-key=\"num\">#</th><th data-key=\"feature\">Feature</th>\n"
            "<th data-key=\"avail\">Available in (upstream)</th>\n"
            "<th data-key=\"franklin\">Franklin (mine)</th>\n"
            "<th data-key=\"backend\">Backend</th><th data-key=\"ui\">UI</th>\n"
            "<th data-key=\"notes\">Notes</th>\n</tr></thead>\n<tbody>\n")
    body = []
    for c in rows:
        num, feat, avail, fran, be, ui, note = c[:7]
        be_rank = BADGE_RANK.get(be, 9)
        ui_rank = BADGE_RANK.get(ui, 9)
        # markdown link in notes -> html anchor
        note = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', note)
        note = re.sub(r"`([^`]+)`", r"<code>\1</code>", note)
        feat_h = re.sub(r"`([^`]+)`", r"<code>\1</code>", feat)
        body.append('<tr data-be="%d" data-ui="%d"><td>%s</td><td>%s</td><td>%s</td>'
                    '<td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>'
                    % (be_rank, ui_rank, num, feat_h, avail, fran, be, ui, note))
    tail = ("</tbody>\n</table>\n<script>\n(function(){\n"
            "  const table = document.getElementById('parity');\n"
            "  const tbody = table.tBodies[0];\n"
            "  let sortDir = {};\n"
            "  const headers = table.tHead.rows[0].cells;\n"
            "  for (let i=0;i<headers.length;i++){\n"
            "    headers[i].addEventListener('click', function(){\n"
            "      const key = this.dataset.key;\n"
            "      const asc = !sortDir[key];\n"
            "      sortDir = {}; sortDir[key]=asc;\n"
            "      const rows = Array.from(tbody.rows);\n"
            "      rows.sort(function(a,b){\n"
            "        let va, vb;\n"
            "        if (key==='num'){ va=parseInt(a.cells[0].textContent); "
            "vb=parseInt(b.cells[0].textContent); }\n"
            "        else if (key==='backend'){ va=+a.dataset.be; vb=+b.dataset.be; }\n"
            "        else if (key==='ui'){ va=+a.dataset.ui; vb=+b.dataset.ui; }\n"
            "        else { va=a.cells[i].textContent.toLowerCase(); "
            "vb=b.cells[i].textContent.toLowerCase(); }\n"
            "        if (va<vb) return asc?-1:1;\n"
            "        if (va>vb) return asc?1:-1;\n"
            "        return 0;\n"
            "      });\n"
            "      rows.forEach(r=>tbody.appendChild(r));\n"
            "    });\n"
            "  }\n"
            "})();\n</script>\n</body>\n</html>\n")
    return head + "\n".join(body) + "\n" + tail


def main():
    check = "--check" in sys.argv
    with open(os.path.join(FEATDIR, "manifest.json"), encoding="utf-8") as fh:
        manifest = json.load(fh)
    with open(MD, encoding="utf-8") as fh:
        md = fh.read()
    new_md = link_rows(md, manifest)
    new_html = md_to_html(new_md)
    if check:
        if new_md != md:
            raise SystemExit("parity table links are out of date; run tools/parity-sync.py")
        with open(HTML, encoding="utf-8") as fh:
            if fh.read() != new_html:
                raise SystemExit("parity HTML is out of date; run tools/parity-sync.py")
        print("OK: %d parity rows linked to existing plans; HTML in sync"
              % len(rows_of(new_md)))
        return
    with open(MD, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(new_md)
    with open(HTML, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(new_html)
    kinds = {}
    for f in manifest["features"]:
        kinds[f["kind"]] = kinds.get(f["kind"], 0) + 1
    print("linked %d parity rows; plans by kind: %s"
          % (len(rows_of(new_md)), ", ".join("%s=%d" % kv for kv in sorted(kinds.items()))))


if __name__ == "__main__":
    main()
