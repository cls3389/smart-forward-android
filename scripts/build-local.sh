#!/bin/bash

# Smart Forward Android 本地构建脚本 (仅需Rust工具链)
set -e

echo "🚀 开始本地构建 Smart Forward Android..."

# 检查Rust是否安装
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust 未安装，请先安装 Rust"
    echo "   安装命令: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# 检查cargo-ndk是否安装
if ! command -v cargo-ndk &> /dev/null; then
    echo "❌ cargo-ndk 未安装，正在安装..."
    cargo install cargo-ndk
fi

# 检查Android目标
echo "📱 检查 Android 目标..."
rustup target add aarch64-linux-android 2>/dev/null || true
rustup target add armv7-linux-androideabi 2>/dev/null || true
rustup target add x86_64-linux-android 2>/dev/null || true
rustup target add i686-linux-android 2>/dev/null || true

# 进入Rust库目录
cd rust-lib

# 清理之前的构建
echo "🧹 清理之前的构建..."
cargo clean

# 构建Android库
echo "📦 构建 Rust 库..."
cargo ndk \
  -t aarch64-linux-android \
  -t armv7-linux-androideabi \
  -t x86_64-linux-android \
  -t i686-linux-android \
  build --release

# 检查构建结果
if [ $? -ne 0 ]; then
    echo "❌ Rust 库构建失败"
    exit 1
fi

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

# 验证文件
echo "✅ Rust 库构建完成！"
echo "📁 库文件位置:"
echo "   - arm64-v8a: app/src/main/jniLibs/arm64-v8a/libsmart_forward.so"
echo "   - armeabi-v7a: app/src/main/jniLibs/armeabi-v7a/libsmart_forward.so"
echo "   - x86_64: app/src/main/jniLibs/x86_64/libsmart_forward.so"
echo "   - x86: app/src/main/jniLibs/x86/libsmart_forward.so"

# 显示文件大小
echo "📊 库文件大小:"
ls -lh ../app/src/main/jniLibs/*/libsmart_forward.so

echo ""
echo "🎉 Rust 库构建成功！"
echo "📱 现在您需要："
echo "   1. 在 Android Studio 中打开项目"
echo "   2. 或者使用云端构建 (GitHub Actions)"
echo "   3. 或者使用 Docker 构建 (WSL + Docker)"
