# android-profile

Codex plugin package for Android SDK and AVD profile scripts used by Docker-based Android emulator images.

## Package Layout

- `.agents/plugins/marketplace.json`: repo-local Codex marketplace entry.
- `.codex-plugin/plugin.json`: plugin manifest.
- `scripts/`: Android SDK, AVD, emulator, and smoke-test scripts.
- `profiles/android.profile`: default Android emulator profile.
- `skills/android-profile/SKILL.md`: Codex-facing usage instructions.

## Install

Install the `android-profile` plugin from this repository's local marketplace:

```text
.agents/plugins/marketplace.json
```

The marketplace entry points to:

```text
./
```

## Direct Script Usage

The packaged scripts can also be run directly from the repository root:

```bash
ANDROID_HOME=$HOME/android-sdk ./scripts/install-sdk.sh
./scripts/create-avd.sh ./profiles/android.profile
./scripts/start-avd.sh ./profiles/android.profile
```

Run the `start-avd.sh` smoke test with fake emulator commands from the repository root:

```bash
scripts/test-start-avd-docker.sh
```
