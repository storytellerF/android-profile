#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TMP_DIR="$(mktemp -d)"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/scripts/profile-utils.sh"

assert_profile_arg_case() {
    local emulator_output avdmanager_output
    local EMULATOR_FLAG_Mixed_Case=true
    local EMULATOR_VALUE_Custom_Value=preserved
    local AVDMANAGER_FLAG_verbose=true
    local AVDMANAGER_VALUE_Custom_Path=/tmp/avd
    local -a emulator_args=()
    local -a avdmanager_args=()

    append_args_from_env emulator_args EMULATOR -
    append_args_from_env avdmanager_args AVDMANAGER --

    emulator_output="$(printf '%s\n' "${emulator_args[@]}")"
    avdmanager_output="$(printf '%s\n' "${avdmanager_args[@]}")"

    grep -qx -- "-Mixed-Case" <<< "$emulator_output"
    grep -qx -- "-Custom-Value" <<< "$emulator_output"
    grep -qx -- "--verbose" <<< "$avdmanager_output"
    grep -qx -- "--Custom-Path" <<< "$avdmanager_output"
}

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

HOME_DIR="${TMP_DIR}/android-home"
FAKE_BIN_DIR="${TMP_DIR}/fake-bin"
PROFILE_PATH="${TMP_DIR}/android.profile"
EMULATOR_ARGS_LOG="${TMP_DIR}/emulator-args.log"
EMULATOR_ENV_LOG="${TMP_DIR}/emulator-env.log"
ADB_ARGS_LOG="${TMP_DIR}/adb-args.log"
START_AVD_OUT="${TMP_DIR}/start-avd.out"
START_AVD_ERR="${TMP_DIR}/start-avd.err"

mkdir -p "${HOME_DIR}/.android/avd/docker-test.avd" "$FAKE_BIN_DIR"
touch "${HOME_DIR}/.android/avd/docker-test.avd/stale.lock"

cat > "${FAKE_BIN_DIR}/emulator" <<'EMULATOR'
#!/usr/bin/env bash
set -euo pipefail
printf "%s\n" "$@" > "${EMULATOR_ARGS_LOG}"
printf "DISPLAY=%s\n" "${DISPLAY:-}" > "${EMULATOR_ENV_LOG}"
exit 0
EMULATOR

cat > "${FAKE_BIN_DIR}/adb" <<'ADB'
#!/usr/bin/env bash
set -euo pipefail
printf "%s\n" "$@" >> "${ADB_ARGS_LOG}"
exit 0
ADB

chmod +x "${FAKE_BIN_DIR}/emulator" "${FAKE_BIN_DIR}/adb"

cat > "$PROFILE_PATH" <<'PROFILE'
AVD_NAME=docker-test-avd
EMULATOR_DISPLAY=:42
EMULATOR_FLAG_no_audio=true
EMULATOR_FLAG_no_snapshot=true
EMULATOR_FLAG_verbose=false
EMULATOR_FLAG_Mixed_Case=true
EMULATOR_VALUE_gpu=swiftshader_indirect
EMULATOR_VALUE_memory=2048
EMULATOR_VALUE_Custom_Value=preserved
PROFILE

echo "Running start-avd.sh smoke test with fake emulator commands..."

assert_profile_arg_case

if ! HOME="$HOME_DIR" \
    PATH="${FAKE_BIN_DIR}:${PATH}" \
    EMULATOR_ARGS_LOG="$EMULATOR_ARGS_LOG" \
    EMULATOR_ENV_LOG="$EMULATOR_ENV_LOG" \
    ADB_ARGS_LOG="$ADB_ARGS_LOG" \
    bash "${PLUGIN_DIR}/scripts/start-avd.sh" "$PROFILE_PATH" > "$START_AVD_OUT" 2> "$START_AVD_ERR"; then
    echo "Error: start-avd.sh failed." >&2
    cat "$START_AVD_OUT" >&2
    cat "$START_AVD_ERR" >&2
    exit 1
fi

grep -q "Starting emulator..." "$START_AVD_OUT"
grep -q "Emulator process has exited." "$START_AVD_OUT"
grep -q -- "-avd" "$EMULATOR_ARGS_LOG"
grep -q "docker-test-avd" "$EMULATOR_ARGS_LOG"
grep -q -- "-no-audio" "$EMULATOR_ARGS_LOG"
grep -q -- "-no-snapshot" "$EMULATOR_ARGS_LOG"
grep -q -- "-gpu" "$EMULATOR_ARGS_LOG"
grep -q "swiftshader_indirect" "$EMULATOR_ARGS_LOG"
grep -q -- "-memory" "$EMULATOR_ARGS_LOG"
grep -q "2048" "$EMULATOR_ARGS_LOG"
grep -q -- "-Mixed-Case" "$EMULATOR_ARGS_LOG"
grep -q -- "-Custom-Value" "$EMULATOR_ARGS_LOG"
grep -q "preserved" "$EMULATOR_ARGS_LOG"
grep -q "DISPLAY=:42" "$EMULATOR_ENV_LOG"

if grep -q -- "-verbose" "$EMULATOR_ARGS_LOG"; then
    echo "Error: false emulator flag was unexpectedly passed." >&2
    exit 1
fi

if [ -e "${HOME_DIR}/.android/avd/docker-test.avd/stale.lock" ]; then
    echo "Error: stale AVD lock file was not removed." >&2
    exit 1
fi

echo "start-avd.sh fake-command smoke test passed."
