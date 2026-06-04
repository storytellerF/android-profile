#!/bin/bash
set -euo pipefail

license_status=0

echo "Accepting Android SDK licenses." >&2
set +o pipefail
yes | sdkmanager --licenses > /dev/null
license_status="${PIPESTATUS[1]}"
set -o pipefail

if [ "$license_status" -ne 0 ]; then
    echo "Error: Failed to accept Android SDK licenses." >&2
    exit "$license_status"
fi

echo "Android SDK license acceptance complete." >&2
