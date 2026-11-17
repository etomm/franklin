/* franklin-mount: minimal mount(2)/umount(2) wrapper.
 *
 * ASUS's busybox `mount` refuses any target that lives on the read-only
 * squashfs root ("Invalid mount path(/www)"), which blocks bind-mounting over
 * /www or /usr/sbin/httpd even though the kernel allows it. This talks to the
 * kernel directly.
 *
 * usage:
 *   franklin-mount bind <src> <dst>
 *   franklin-mount overlay <opts> <dst>
 *   franklin-mount umount <dst>
 */
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/mount.h>

int main(int argc, char **argv)
{
    if (argc < 3) {
        fprintf(stderr, "usage: %s bind <src> <dst> | overlay <opts> <dst> | umount <dst>\n", argv[0]);
        return 2;
    }
    const char *cmd = argv[1];
    int r;

    if (!strcmp(cmd, "bind") && argc == 4) {
        r = mount(argv[2], argv[3], NULL, MS_BIND, NULL);
    } else if (!strcmp(cmd, "overlay") && argc == 4) {
        r = mount("overlay", argv[3], "overlay", 0, argv[2]);
    } else if (!strcmp(cmd, "remount-ro") && argc == 3) {
        r = mount(NULL, argv[2], NULL, MS_REMOUNT | MS_RDONLY | MS_BIND, NULL);
    } else if (!strcmp(cmd, "umount") && argc == 3) {
        r = umount2(argv[2], 0);
    } else {
        fprintf(stderr, "bad arguments\n");
        return 2;
    }

    if (r != 0) {
        fprintf(stderr, "%s %s: %s\n", cmd, argv[argc - 1], strerror(errno));
        return 1;
    }
    return 0;
}
