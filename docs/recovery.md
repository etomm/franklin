# Recovery

## If a boot script breaks the router
1. Remove the USB stick and reboot (asusware.arm hook will not run).
2. SSH in using the key saved in ASUS settings.
3. Fix scripts on /jffs or the USB stick from a working machine.
4. Re-insert USB and reboot.

## If SSH is unavailable
- Use the hardware reset / console path documented for the model.
- Restore stock firmware via ASUS rescue mode if needed.

## Never do
- Patch /sbin, /usr/sbin, httpd, rc, init, or kernel/drivers without a recovery plan.
- Persist an untested kernel module.
