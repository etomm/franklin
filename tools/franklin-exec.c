/* franklin-exec: exec a program under a different argv[0].
 *
 * Why this exists: ASUS's watchdog checks `pidof httpd`. A wrapper that execs
 * `gnuton-httpd` shows up as "gnuton-httpd", so the watchdog believes httpd is
 * dead and restarts it every 30 seconds (observed in syslog). Running the same
 * binary with argv[0] = "httpd" makes every name-based check (watchdog, pidof,
 * killall, service restart_httpd) behave as if the stock daemon were running.
 *
 * usage: franklin-exec <argv0> <program> [args...]
 *
 * example:
 *   franklin-exec httpd /opt/bin/gnuton-httpd -p 80
 *   -> execv("/opt/bin/gnuton-httpd", {"httpd", "-p", "80", NULL})
 */
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv)
{
    if (argc < 3) {
        fprintf(stderr, "usage: %s <argv0> <program> [args...]\n", argv[0]);
        return 2;
    }

    const char *prog = argv[2];

    /* argv[1..] is reused as the new vector: argv[1] becomes argv[0], and the
     * program's own arguments start at argv[3]. */
    char **na = &argv[1];
    int i;
    for (i = 1; i + 2 < argc; i++)
        na[i] = argv[i + 2];
    na[argc - 2] = NULL;

    execv(prog, na);
    fprintf(stderr, "franklin-exec: execv %s: %s\n", prog, strerror(errno));
    return 127;
}
