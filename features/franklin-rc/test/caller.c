#include <string.h>

void notify_rc(const char *service);
void notify_rc_after_wait(const char *service);
void notify_rc_and_wait(const char *service);
void notify_rc_after_period_wait(const char *service, int secs);

int main(int argc, char **argv)
{
    if (argc < 3) {
        return 2;
    }
    /* argv[1] selects the variant httpd uses; the rest are action names. */
    if (strcmp(argv[1], "plain") == 0) {
        notify_rc(argv[2]);
        notify_rc(argv[3] ? argv[3] : argv[2]);
    } else if (strcmp(argv[1], "after_wait") == 0) {
        notify_rc_after_wait(argv[2]);
    } else if (strcmp(argv[1], "and_wait") == 0) {
        notify_rc_and_wait(argv[2]);
    } else if (strcmp(argv[1], "period") == 0) {
        notify_rc_after_period_wait(argv[2], 30);
    } else {
        return 2;
    }
    return 0;
}
