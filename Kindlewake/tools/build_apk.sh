#!/bin/sh
# Linux wrapper: builds dist/Kindlewake.apk (see tools/build_apk.py --help)
cd "$(dirname "$0")/.." || exit 1
exec python3 tools/build_apk.py "$@"
