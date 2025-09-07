#!/bin/bash

# Smart Forward Android 构建脚本
set -e

echo "🚀 开始构建 Smart Forward Android 库..."

# 检查环境
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust 未安装，请先安装 Rust"
    exit 1
fi

if ! command -v cargo-ndk &> /dev/null; then
    echo "❌ cargo-ndk 未安装，请运行: cargo install cargo-ndk"
    exit 1
fi

# 检查 Android 目标
echo "📱 检查 Android 目标..."
rustup target add aarch64-linux-android 2>/dev/null || true
rustup target add armv7-linux-androideabi 2>/dev/null || true
rustup target add x86_64-linux-android 2>/dev/null || true
rustup target add i686-linux-android 2>/dev/null || true

# 进入 Rust 库目录
cd rust-lib

# 清理之前的构建
echo "🧹 清理之前的构建..."
cargo clean

# 构建 Android 库
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
echo "✅ 构建完成！"
echo "📁 库文件位置:"
echo "   - arm64-v8a: app/src/main/jniLibs/arm64-v8a/libsmart_forward.so"
echo "   - armeabi-v7a: app/src/main/jniLibs/armeabi-v7a/libsmart_forward.so"
echo "   - x86_64: app/src/main/jniLibs/x86_64/libsmart_forward.so"
echo "   - x86: app/src/main/jniLibs/x86/libsmart_forward.so"

# 显示文件大小
echo "📊 库文件大小:"
ls -lh ../app/src/main/jniLibs/*/libsmart_forward.so

echo "🎉 构建成功！现在可以在 Android Studio 中打开项目了。"
