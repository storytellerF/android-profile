# android-profile

Shared Android SDK and AVD profile scripts for Docker-based Android emulator images.

## Contents

- `scripts/install-sdk.sh`: installs or updates Android SDK command-line tools, accepts licenses, and installs `platform-tools` and `emulator`.
- `scripts/create-avd.sh`: installs the configured system image and creates the AVD when it does not already exist.
- `scripts/start-avd.sh`: starts the configured Android Emulator and shuts it down cleanly on `SIGTERM` or `SIGINT`.
- `scripts/test-start-avd-docker.sh`: runs `start-avd.sh` in an isolated Docker container with fake Android tools.
- `scripts/profile-utils.sh`: loads profile files and maps profile variables into command-line flags.
- `profiles/android.profile`: default Android emulator profile.

## Profile Usage

`create-avd.sh` and `start-avd.sh` load the profile from the first argument when provided. Otherwise they use:

```bash
${ANDROID_PROFILE:-${ANDROID_PROFILE_DIR:-$HOME/android-profiles}/android.profile}
```

`SYS_IMG_PKG` must be the system image package prefix without an ABI suffix, for example:

```bash
SYS_IMG_PKG='system-images;android-36;google_apis'
```

The scripts append the ABI dynamically from the runtime architecture:

- `x86_64` -> `x86_64`
- `aarch64` -> `arm64-v8a`

## Integration

Projects such as `android-in-docker` can include this repository as a Git submodule and copy:

- `scripts/*.sh` into the image user's `bin` directory
- `profiles/*` into the image user's `android-profiles` directory

For `android-in-docker`, initialize submodules after cloning:

```bash
git submodule update --init --recursive
```

## Script Tests

Run the isolated `start-avd.sh` smoke test with Docker:

```bash
scripts/test-start-avd-docker.sh
```

The test mounts this repository read-only into a clean container, injects fake `emulator` and `adb` commands, and verifies profile loading, emulator argument generation, display export, and stale AVD lock cleanup. Override the image when needed:

```bash
DOCKER_IMAGE=bash:5.2 scripts/test-start-avd-docker.sh
```
