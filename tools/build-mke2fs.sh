#!/bin/sh
# Build a static ARM mke2fs (e2fsprogs) so a router can format a stick as ext4
# by itself. Stock busybox only ships mkfs.ext2/mkfs.ext3, but the kernel has
# CONFIG_EXT4_FS=y, so the only missing piece is the userspace tool.
#
# Run inside WSL/Debian (needs wget, make, and an ARM cross compiler):
#   tools/build-mke2fs.sh [version] [outdir]
#
# Then, on the router:
#   umount /tmp/mnt/<label>
#   /tmp/mke2fs -q -t ext4 -L FRANKLIN /dev/sda
#
# Verified on the XT9: mke2fs 1.47.2 (static, 1.1 MB) creates an ext4 image and
# the stock kernel mounts it rw.
set -eu
VERSION="${1:-1.47.2}"
OUTDIR="${2:-/tmp}"
URL="https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${VERSION}/e2fsprogs-${VERSION}.tar.gz"
CROSS="${CROSS_COMPILE:-arm-linux-gnueabi-}"

command -v "${CROSS}gcc" >/dev/null || { echo "missing ${CROSS}gcc" >&2; exit 1; }
command -v "${CROSS}strip" >/dev/null || { echo "missing ${CROSS}strip" >&2; exit 1; }

cd "$OUTDIR"
[ -f "e2fsprogs-${VERSION}.tar.gz" ] || wget -q "$URL"
rm -rf "e2fsprogs-${VERSION}"
tar xzf "e2fsprogs-${VERSION}.tar.gz"
cd "e2fsprogs-${VERSION}"

./configure --host="${CROSS%gcc}" --build="$(gcc -dumpmachine)" \
    --disable-nls --disable-elf-shlibs --enable-static \
    --disable-fuse2fs --disable-defrag --disable-imager \
    --disable-debugfs --disable-e2initrd-helper \
    LDFLAGS="-static" >/tmp/e2fs-configure.log 2>&1

make -j"$(nproc)" libs >/tmp/e2fs-libs.log 2>&1
make -j"$(nproc)" -C misc mke2fs >/tmp/e2fs-build.log 2>&1

"${CROSS}strip" misc/mke2fs -o "$OUTDIR/mke2fs"
ls -l "$OUTDIR/mke2fs"
