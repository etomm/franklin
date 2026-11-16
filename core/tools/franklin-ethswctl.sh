#!/bin/sh
# Wrapper around ethswctl for Franklin. Usage:
#   franklin-ethswctl.sh apply   # apply verified sequence
#   franklin-ethswctl.sh status  # print current state
case "${1:-status}" in
  apply)
    /bin/ethswctl -c hw-switching -o enable
    /bin/ethswctl -c softswitch -i eth0 -o enable
    /bin/ethswctl -c softswitch -i eth1 -o enable
    ;;
  status)
    echo "hw-switching: $(/bin/ethswctl -c hw-switching)"
    echo "softswitch:   $(/bin/ethswctl -c softswitch)"
    ;;
  *)
    echo "usage: $0 {apply|status}" >&2
    exit 2
    ;;
esac
