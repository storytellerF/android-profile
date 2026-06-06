# android-profile

用于 Docker Android 模拟器镜像的 Codex 插件包，包含 Android SDK 和 AVD 配置脚本。

## 包结构

- `.agents/plugins/marketplace.json`：仓库内的 Codex marketplace 条目。
- `plugins/android-profile/.codex-plugin/plugin.json`：插件清单文件。
- `plugins/android-profile/scripts/`：Android SDK、AVD 和模拟器脚本。
- `plugins/android-profile/tests/`：冒烟测试脚本。
- `plugins/android-profile/profiles/android.profile`：默认 Android 模拟器配置。
- `plugins/android-profile/skills/android-profile/SKILL.md`：面向 Codex 的使用说明。

## 安装

将此 GitHub 仓库添加为 Codex 插件 marketplace：

```bash
codex plugin marketplace add https://github.com/storytellerF/android-profile
```

从该 marketplace 安装插件：

```bash
codex plugin add android-profile@android-profile-local
```

安装后启动一个新的 Codex 线程，以便加载插件 skill。

## 直接使用脚本

也可以在插件根目录下直接运行打包好的脚本：

```bash
cd plugins/android-profile
ANDROID_HOME=$HOME/android-sdk ./scripts/install-sdk.sh
./scripts/create-avd.sh ./profiles/android.profile
./scripts/start-avd.sh ./profiles/android.profile
```

在仓库根目录下使用假的模拟器命令运行 `start-avd.sh` 冒烟测试：

```bash
plugins/android-profile/tests/test-start-avd-docker.sh
```
