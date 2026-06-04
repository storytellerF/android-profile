---
name: android-profile
description: Use bundled Android SDK and AVD profile scripts to install Android SDK tools, create Android Virtual Devices, start Docker-friendly emulators, and run the start-avd smoke test.
---

# Android Profile

Use this skill when a task involves this plugin's Android SDK, AVD, emulator, or Docker smoke-test scripts.

## Bundled Paths

Resolve paths relative to this plugin root:

- `scripts/install-sdk.sh`
- `scripts/accept-sdk-licenses.sh`
- `scripts/create-avd.sh`
- `scripts/start-avd.sh`
- `scripts/profile-utils.sh`
- `tests/test-start-avd-docker.sh`
- `profiles/android.profile`

## Workflows

Install or update Android SDK tools:

```bash
ANDROID_HOME=${ANDROID_HOME:-$HOME/android-sdk} ./scripts/install-sdk.sh
```

Create the configured AVD:

```bash
./scripts/create-avd.sh ./profiles/android.profile
```

Start the configured emulator:

```bash
./scripts/start-avd.sh ./profiles/android.profile
```

Run the fake-command smoke test from the repository root:

```bash
tests/test-start-avd-docker.sh
```

## Profile Rules

- Pass a profile path as the first argument when using a non-default profile.
- If no profile path is passed, `create-avd.sh` and `start-avd.sh` use `${ANDROID_PROFILE:-${ANDROID_PROFILE_DIR:-$HOME/android-profiles}/android.profile}`.
- `SYS_IMG_PKG` must be the Android system image package prefix without the ABI suffix.
- The scripts append the ABI from the runtime architecture: `x86_64` uses `x86_64`, and `aarch64` uses `arm64-v8a`.
- Do not define `ARCH`, `ABI`, `AVD_ARCH`, `AVD_ABI`, `AVDMANAGER_ABI`, `AVDMANAGER_ARCH`, `EMULATOR_ABI`, or `EMULATOR_ARCH` in profiles.

## Notes For Codex

- Prefer running scripts from the plugin root so relative paths work naturally.
- Ask before running workflows that download SDK packages or start long-lived emulator processes.
- `test-start-avd-docker.sh` uses fake `emulator` and `adb` commands; it does not start Docker or a real emulator.
