#include <stdio.h>
#include <stdlib.h>

/* Stand-in for libshared's notify_rc family, recording what reached stock rc.
   The real library exposes seven variants with these signatures. */
static void record(const char *variant, const char *service)
{
    const char *log = getenv("PROVIDER_LOG");
    FILE *f = fopen(log ? log : "/dev/null", "a");
    if (f) {
        fprintf(f, "%s %s\n", variant, service ? service : "(null)");
        fclose(f);
    }
}

void notify_rc(const char *service) { record("notify_rc", service); }
void notify_rc_after_wait(const char *service) { record("notify_rc_after_wait", service); }
void notify_rc_and_wait(const char *service) { record("notify_rc_and_wait", service); }
void notify_rc_and_wait_1min(const char *service) { record("notify_rc_and_wait_1min", service); }
void notify_rc_and_wait_2min(const char *service) { record("notify_rc_and_wait_2min", service); }
void notify_rc_after_period_wait(const char *service, int secs) { (void)secs; record("notify_rc_after_period_wait", service); }
void notify_rc_and_period_wait(const char *service, int secs) { (void)secs; record("notify_rc_and_period_wait", service); }
