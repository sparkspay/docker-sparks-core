#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for sparksd"

  set -- sparksd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "sparksd" ]; then
  mkdir -p "$SPARKS_DATA"
  chmod 700 "$SPARKS_DATA"
  chown -R sparks "$SPARKS_DATA"

  echo "$0: setting data directory to $SPARKS_DATA"

  set -- "$@" -datadir="$SPARKS_DATA"
fi

if [ "$1" = "sparksd" ] || [ "$1" = "sparks-cli" ] || [ "$1" = "sparks-tx" ]; then
  echo
  exec su-exec sparks "$@"
fi

echo
exec "$@"
