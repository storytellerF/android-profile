#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCKER_IMAGE="${DOCKER_IMAGE:-bash:5.2}"

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is required to run this test." >&2
    exit 1
fi

echo "Running start-avd.sh in isolated Docker container..."
echo "Docker image: ${DOCKER_IMAGE}"

docker run --rm \
    --volume "${REPO_DIR}:/workspace:ro" \
    --workdir /workspace \
    --env HOME=/tmp/android-home \
    "${DOCKER_IMAGE}" \
    bash -lc '
set -euo pipefail

mkdir -p /tmp/android-home/.android/avd/docker-test.avd
touch /tmp/android-home/.android/avd/docker-test.avd/stale.lock

mkdir -p /tmp/fake-bin
cat > /tmp/fake-bin/emulator <<'"'"'EMULATOR'"'"'
#!/usr/bin/env bash
set -euo pipefail
printf "%s\n" "$@" > /tmp/emulator-args.log
printf "DISPLAY=%s\n" "${DISPLAY:-}" > /tmp/emulator-env.log
exit 0
EMULATOR

cat > /tmp/fake-bin/adb <<'"'"'ADB'"'"'
#!/usr/bin/env bash
set -euo pipefail
printf "%s\n" "$@" >> /tmp/adb-args.log
exit 0
ADB

chmod +x /tmp/fake-bin/emulator /tmp/fake-bin/adb
export PATH="/tmp/fake-bin:${PATH}"

cat > /tmp/android.profile <<'"'"'PROFILE'"'"'
AVD_NAME=docker-test-avd
EMULATOR_DISPLAY=:42
EMULATOR_FLAG_NO_AUDIO=true
EMULATOR_FLAG_NO_SNAPSHOT=true
EMULATOR_FLAG_VERBOSE=false
EMULATOR_VALUE_GPU=swiftshader_indirect
EMULATOR_VALUE_MEMORY=2048
PROFILE

if ! bash /workspace/scripts/start-avd.sh /tmp/android.profile > /tmp/start-avd.out 2> /tmp/start-avd.err; then
    echo "Error: start-avd.sh failed inside Docker." >&2
    cat /tmp/start-avd.out >&2
    cat /tmp/start-avd.err >&2
    exit 1
fi

grep -q "Starting emulator..." /tmp/start-avd.out
grep -q "Emulator process has exited." /tmp/start-avd.out
grep -q -- "-avd" /tmp/emulator-args.log
grep -q "docker-test-avd" /tmp/emulator-args.log
grep -q -- "-no-audio" /tmp/emulator-args.log
grep -q -- "-no-snapshot" /tmp/emulator-args.log
grep -q -- "-gpu" /tmp/emulator-args.log
grep -q "swiftshader_indirect" /tmp/emulator-args.log
grep -q -- "-memory" /tmp/emulator-args.log
grep -q "2048" /tmp/emulator-args.log
grep -q "DISPLAY=:42" /tmp/emulator-env.log

if grep -q -- "-verbose" /tmp/emulator-args.log; then
    echo "Error: false emulator flag was unexpectedly passed." >&2
    exit 1
fi

if [ -e /tmp/android-home/.android/avd/docker-test.avd/stale.lock ]; then
    echo "Error: stale AVD lock file was not removed." >&2
    exit 1
fi

echo "start-avd.sh Docker isolation test passed."
'
