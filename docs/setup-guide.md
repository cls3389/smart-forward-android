# Smart Forward Android 开发环境搭建指南

## 📋 环境要求

### 1. 系统要求
- **操作系统**: Windows 10/11, macOS, Linux
- **内存**: 至少 8GB RAM
- **存储**: 至少 10GB 可用空间
- **网络**: 稳定的互联网连接

### 2. 软件要求
- **Android Studio**: 2023.1.1 或更高版本
- **JDK**: 17 或更高版本
- **Rust**: 1.70 或更高版本
- **Git**: 2.30 或更高版本

## 🚀 安装步骤

### 步骤 1: 安装 Android Studio

#### Windows
1. 下载 Android Studio
   ```bash
   # 访问 https://developer.android.com/studio
   # 下载 Android Studio 2023.1.1 或更高版本
   ```

2. 安装 Android Studio
   ```bash
   # 运行下载的安装程序
   # 选择 "Standard" 安装类型
   # 确保勾选 "Android SDK" 和 "Android SDK Platform"
   ```

3. 配置 Android SDK
   ```bash
   # 打开 Android Studio
   # 进入 File -> Settings -> Appearance & Behavior -> System Settings -> Android SDK
   # 安装以下组件：
   # - Android 14.0 (API 34)
   # - Android 13.0 (API 33)
   # - Android 12.0 (API 31)
   # - Android 11.0 (API 30)
   # - Android 10.0 (API 29)
   # - Android 9.0 (API 28)
   # - Android 8.0 (API 26)
   # - Android 7.0 (API 24)
   ```

#### macOS
```bash
# 使用 Homebrew 安装
brew install --cask android-studio

# 或者手动下载安装
# 访问 https://developer.android.com/studio
```

#### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install openjdk-17-jdk
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.28/android-studio-2023.1.1.28-linux.tar.gz
tar -xzf android-studio-2023.1.1.28-linux.tar.gz
sudo mv android-studio /opt/
sudo ln -s /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio
```

### 步骤 2: 安装 Rust

#### Windows
```bash
# 下载并安装 Rust
# 访问 https://rustup.rs/
# 下载并运行 rustup-init.exe
# 选择 "1) Proceed with installation (default)"

# 验证安装
rustc --version
cargo --version
```

#### macOS
```bash
# 使用 Homebrew 安装
brew install rust

# 或者使用官方安装脚本
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

#### Linux
```bash
# 使用官方安装脚本
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# 验证安装
rustc --version
cargo --version
```

### 步骤 3: 安装 Rust Android 工具链

```bash
# 添加 Android 目标
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android

# 安装 cargo-ndk
cargo install cargo-ndk

# 验证安装
cargo ndk --version
```

### 步骤 4: 配置 Android NDK

#### 方法一: 通过 Android Studio
1. 打开 Android Studio
2. 进入 File -> Settings -> Appearance & Behavior -> System Settings -> Android SDK
3. 切换到 "SDK Tools" 标签
4. 勾选 "NDK (Side by side)" 并安装
5. 记录 NDK 路径（通常在 `~/Android/Sdk/ndk/` 目录下）

#### 方法二: 手动安装
```bash
# 下载 NDK
wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip

# 解压到指定目录
unzip android-ndk-r25c-linux.zip
sudo mv android-ndk-r25c /opt/
export ANDROID_NDK_ROOT=/opt/android-ndk-r25c
```

### 步骤 5: 配置环境变量

#### Windows
```powershell
# 设置环境变量
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:ANDROID_NDK_ROOT = "$env:ANDROID_HOME\ndk\25.2.9519653"
$env:PATH += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools"

# 永久设置（需要管理员权限）
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $env:ANDROID_HOME, "User")
[Environment]::SetEnvironmentVariable("ANDROID_NDK_ROOT", $env:ANDROID_NDK_ROOT, "User")
```

#### macOS/Linux
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_NDK_ROOT=$ANDROID_HOME/ndk/25.2.9519653
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools

# 重新加载配置
source ~/.bashrc  # 或 source ~/.zshrc
```

### 步骤 6: 验证环境

```bash
# 验证 Android 环境
adb version
android --version

# 验证 Rust 环境
rustc --version
cargo --version

# 验证 NDK 环境
cargo ndk --version

# 验证 Android 目标
rustup target list --installed | grep android
```

## 🏗️ 项目初始化

### 1. 创建项目目录
```bash
# 创建项目根目录
mkdir smart-forward-android
cd smart-forward-android

# 创建子目录
mkdir -p app/src/main/java/com/smartforward
mkdir -p app/src/main/res
mkdir -p rust-lib/src
mkdir -p docs
mkdir -p scripts
```

### 2. 初始化 Rust 库
```bash
cd rust-lib
cargo init --lib

# 编辑 Cargo.toml
cat > Cargo.toml << EOF
[package]
name = "smart-forward-lib"
version = "0.1.0"
edition = "2021"

[lib]
name = "smart_forward"
crate-type = ["cdylib"]

[dependencies]
jni = "0.21"
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_yaml = "0.9"
log = "0.4"

[target.'cfg(target_os = "android")'.dependencies]
android_logger = "0.13"
EOF
```

### 3. 创建 Android 项目
```bash
# 使用 Android Studio 创建新项目
# 或者使用命令行工具
cd ..
android create project \
  --target android-34 \
  --name SmartForward \
  --path app \
  --activity MainActivity \
  --package com.smartforward
```

### 4. 创建构建脚本
```bash
# 创建构建脚本
cat > scripts/build-android.sh << 'EOF'
#!/bin/bash

# 设置错误时退出
set -e

echo "🚀 开始构建 Android 库..."

# 检查环境
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust 未安装"
    exit 1
fi

if ! command -v cargo-ndk &> /dev/null; then
    echo "❌ cargo-ndk 未安装"
    exit 1
fi

# 构建 Android 库
echo "📦 构建 Rust 库..."
cd rust-lib

# 清理之前的构建
cargo clean

# 构建所有 Android 目标
cargo ndk \
  -t aarch64-linux-android \
  -t armv7-linux-androideabi \
  -t x86_64-linux-android \
  -t i686-linux-android \
  build --release

echo "📱 复制库文件到 Android 项目..."

# 创建目标目录
mkdir -p ../app/src/main/jniLibs/arm64-v8a
mkdir -p ../app/src/main/jniLibs/armeabi-v7a
mkdir -p ../app/src/main/jniLibs/x86_64
mkdir -p ../app/src/main/jniLibs/x86

# 复制库文件
cp target/aarch64-linux-android/release/libsmart_forward.so ../app/src/main/jniLibs/arm64-v8a/
cp target/armv7-linux-androideabi/release/libsmart_forward.so ../app/src/main/jniLibs/armeabi-v7a/
cp target/x86_64-linux-android/release/libsmart_forward.so ../app/src/main/jniLibs/x86_64/
cp target/i686-linux-android/release/libsmart_forward.so ../app/src/main/jniLibs/x86/

echo "✅ 构建完成！"
echo "📁 库文件位置:"
echo "   - arm64-v8a: app/src/main/jniLibs/arm64-v8a/libsmart_forward.so"
echo "   - armeabi-v7a: app/src/main/jniLibs/armeabi-v7a/libsmart_forward.so"
echo "   - x86_64: app/src/main/jniLibs/x86_64/libsmart_forward.so"
echo "   - x86: app/src/main/jniLibs/x86/libsmart_forward.so"
EOF

chmod +x scripts/build-android.sh
```

## 🧪 测试环境

### 1. 创建测试项目
```bash
# 创建简单的测试项目
cat > test-android.sh << 'EOF'
#!/bin/bash

echo "🧪 测试 Android 环境..."

# 测试 Rust 编译
echo "测试 Rust 编译..."
cd rust-lib
cargo check
echo "✅ Rust 编译测试通过"

# 测试 Android 目标
echo "测试 Android 目标..."
cargo ndk -t aarch64-linux-android build --release
echo "✅ Android 目标编译测试通过"

# 测试 Android 项目
echo "测试 Android 项目..."
cd ../app
./gradlew assembleDebug
echo "✅ Android 项目编译测试通过"

echo "🎉 所有测试通过！环境配置成功！"
EOF

chmod +x test-android.sh
```

### 2. 运行测试
```bash
./test-android.sh
```

## 🔧 常见问题

### 问题 1: NDK 路径问题
```bash
# 错误: NDK not found
# 解决: 设置正确的 NDK 路径
export ANDROID_NDK_ROOT=/path/to/ndk
```

### 问题 2: Rust 目标未安装
```bash
# 错误: target not found
# 解决: 安装缺失的目标
rustup target add aarch64-linux-android
```

### 问题 3: 权限问题
```bash
# 错误: Permission denied
# 解决: 给脚本添加执行权限
chmod +x scripts/build-android.sh
```

### 问题 4: 内存不足
```bash
# 错误: Out of memory
# 解决: 增加交换空间或关闭其他程序
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## 📚 参考资源

- [Android 开发文档](https://developer.android.com/)
- [Rust Android 开发指南](https://mozilla.github.io/firefox-browser-architecture/experiments/2017-09-21-rust-on-android.html)
- [JNI 开发指南](https://docs.oracle.com/javase/8/docs/technotes/guides/jni/)
- [Jetpack Compose 文档](https://developer.android.com/jetpack/compose)

---

**文档版本**: v1.0  
**最后更新**: 2024-12-19  
**状态**: 📋 计划阶段
