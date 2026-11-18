# Building gnuton's httpd for XT8PRO (ZenWiFi XT9)

Why: gnuton publishes no XT8PRO target. Our node (`productid=XT8PRO`,
`/proc/device-tree/model=XT8PRO_GPY211`) runs an RT-AX95Q build, which is why the
wireless log mis-parses `sta_info`, `get_all_accounts()` is empty and WiFi
Insight has no `json.cgi`. This is the CI recipe to produce a correct httpd.

Everything here is GPL material from the XT9 firmware tarball, kept so the build
is reproducible. Build on GitHub Actions — a local build needs ~30 GB and this
machine has ~9 GB free.

## 0. Fork

Fork `Asuswrt-Merlin/asuswrt-merlin.ng-gnuton` and check out tag
`3004.388.11_1-gnuton1` (or `master` if you prefer living on HEAD).

## 1. Add the model files

Upload these four files from this folder into the fork, keeping paths:

```
release/src-rt-5.04axhnd.675x/targets/96756GW/96756GW.XT8PRO
release/src-rt-5.04axhnd.675x/targets/96756GW/96756GW.XT8PRO_GPY211
release/src-rt-5.04axhnd.675x/targets/nvram/6756/XT8PRO.nvm
release/src-rt-5.04axhnd.675x/targets/nvram/6756/XT8PRO_GPY211.nvm
```

(GitHub web UI: "Add file → Upload files", then rename if the upload flattens
directories.)

## 2. Register the model

In `release/src-rt/target.mak`, immediately after the `HND-96756_BASE`
definitions, paste the contents of [target.mak.snippet](target.mak.snippet):

```make
export XT8PRO := $(HND-96756_BASE)
export XT8PRO += BUILD_NAME="XT8PRO" ...
export XT8PRO_CFG := $(XT8PRO)
```

The block is the exact one ASUS uses for this model (same `HND-96756_BASE` that
gnuton builds for `TUF-AX3000_V2` and `RT-AX58U_V2`).

## 3. Add it to the CI matrix

In `.github/workflows/github-actions.yml`, add one line to the matrix:

```yaml
            - { model: "xt8pro", sdk: "src-rt-5.04axhnd.675x", ui: "default", skip: false }
```

Commit to a branch (e.g. `xt8pro-build`) and push.

## 4. Run and collect

Actions → Images → the run for your branch. Expect 1–2 h. The job uploads
`release-xt8pro-default`; inside is `XT8PRO_3004_388.11_1-gnuton1_puresqubi.w`
(~50 MB).

## 5. What we do with it

```sh
# extract the rootfs from the image (squashfs), then take httpd and the libs
unsquashfs -d /tmp/xt8pro XT8PRO_*_puresqubi.w     # or binwalk/ubi tools
/tmp/xt8pro/usr/sbin/httpd --help
sh tools/lib-audit.sh <lib>      # decide per library, keep stock unless exports demand gnuton
```

Then test on `:8089` with the vendor pages before shipping:

- `Main_WStatus_Content.asp` → station rows, no `,AU"]`
- `Advanced_System_Content.asp` → `var accounts = ["admin"];`
- `strings httpd | grep json.cgi` → non-empty (WiFi Insight backend present)

If those pass, the page patches #1/#2 (and the MIT WiFi Insight substitute) can
be deleted.

## Notes / risks

- `XT8PRO_GPY211` is the exact board; `XT8PRO` is the model name ASUS builds
  (both config files are included). If the build wants the variant, register it
  the same way with `BUILD_NAME="XT8PRO_GPY211"`.
- The image is for a different firmware line than ours (`388.11` vs `388_24854`);
  for httpd/www this is acceptable — we ship only the binary and matching libs,
  and the audit decides which libraries may be replaced.
- If `make xt8pro` complains about a missing model mapping, the build system
  upper-cases the name (`xt8pro` → `XT8PRO`); the `target.mak` entry must exist
  before the matrix line is used.
