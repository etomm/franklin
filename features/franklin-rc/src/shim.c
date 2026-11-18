/*
 * libfranklin_rc.so - LD_PRELOAD shim over httpd's rc trigger.
 *
 * The gnuton httpd we serve has `notify_rc` as an undefined symbol (see
 * `nm -D httpd`), resolved from libshared at load time. Stock rc is pid 1 and
 * cannot be patched or subscribed to, so this shim is the seam: for actions
 * Franklin implements, hand the action to `franklin-rc` instead of signalling
 * init; for everything else, call the real function and change nothing.
 *
 * Signatures, recovered from libshared's thunks: every variant takes the
 * service name, the two *_period_wait ones also take the wait in seconds.
 *
 *   notify_rc(s)                  wait 15s, no init wait
 *   notify_rc_after_wait(s)       wait 30s, no init wait
 *   notify_rc_and_wait(s)         wait 10s, then wait for init
 *   notify_rc_and_wait_1min(s)    60s
 *   notify_rc_and_wait_2min(s)    120s
 *   notify_rc_after_period_wait(s, secs)
 *   notify_rc_and_period_wait(s, secs)
 *
 * The action table is generated from the actions directory by build.sh into
 * actions.h, so adding a handler never touches this file.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "actions.h"

/* Child processes are fire-and-forget: rc actions are asynchronous, and httpd
 * must not block on a handler while answering the browser. */
static void run_companion(const char *service)
{
    const char *rc = getenv("FRANKLIN_RC");
    pid_t pid;

    if (!rc || !*rc) {
        return;
    }
    pid = fork();
    if (pid == 0) {
        execl(rc, "franklin-rc", service, (char *)NULL);
        _exit(127);
    }
}

static int franklin_handles(const char *service)
{
    int i;

    if (!service || !*service) {
        return 0;
    }
    for (i = 0; franklin_actions[i]; i++) {
        if (strcmp(franklin_actions[i], service) == 0) {
            return 1;
        }
    }
    return 0;
}

#define FORWARD(name, proto, call)                                       \
    void name proto                                                    \
    {                                                                  \
        static void (*real) proto;                                     \
        if (franklin_handles(service)) {                                \
            run_companion(service);                                    \
            return;                                                    \
        }                                                              \
        if (!real) {                                                   \
            real = (void (*) proto)dlsym(RTLD_NEXT, #name);             \
        }                                                              \
        if (real) {                                                    \
            call;                                                      \
        }                                                              \
    }

FORWARD(notify_rc,                     (const char *service),           real(service))
FORWARD(notify_rc_after_wait,          (const char *service),           real(service))
FORWARD(notify_rc_and_wait,            (const char *service),           real(service))
FORWARD(notify_rc_and_wait_1min,       (const char *service),           real(service))
FORWARD(notify_rc_and_wait_2min,       (const char *service),           real(service))
FORWARD(notify_rc_after_period_wait,   (const char *service, int secs), real(service, secs))
FORWARD(notify_rc_and_period_wait,     (const char *service, int secs), real(service, secs))
