# android-profile

Codex plugin package for Android SDK and AVD profile scripts used by Docker-based Android emulator images.

## Package Layout

- `.agents/plugins/marketplace.json`: repo-local Codex marketplace entry.
- `plugins/android-profile/.codex-plugin/plugin.json`: plugin manifest.
- `plugins/android-profile/scripts/`: Android SDK, AVD, emulator, and smoke-test scripts.
- `plugins/android-profile/profiles/android.profile`: default Android emulator profile.
- `plugins/android-profile/skills/android-profile/SKILL.md`: Codex-facing usage instructions.

## Install

Add this GitHub repository as a Codex plugin marketplace:

```bash
codex plugin marketplace add https://github.com/storytellerF/android-profile
```

Install the plugin from that marketplace:

```bash
codex plugin add android-profile@android-profile-local
```

Start a new Codex thread after installing so the plugin skill is loaded.

## Direct Script Usage

The packaged scripts can also be run directly from the plugin root:

```bash
cd plugins/android-profile
ANDROID_HOME=$HOME/android-sdk ./scripts/install-sdk.sh
./scripts/create-avd.sh ./profiles/android.profile
./scripts/start-avd.sh ./profiles/android.profile
```

Run the `start-avd.sh` smoke test with fake emulator commands from the repository root:

```bash
plugins/android-profile/scripts/test-start-avd-docker.sh
```
