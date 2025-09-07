#!/bin/bash

# Smart Forward Android Docker 构建脚本
set -e

echo "🚀 开始使用 Docker 构建 Smart Forward Android..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 构建Docker镜像
echo "📦 构建 Docker 镜像..."
docker build -t smart-forward-android .

# 创建输出目录
mkdir -p build/outputs

# 运行Docker容器进行构建
echo "🔨 在 Docker 容器中构建..."
docker run --rm \
    -v "$(pwd):/workspace" \
    -w /workspace \
    smart-forward-android \
    bash -c "
        echo '📱 构建 Rust 库...'
        cd rust-lib
        
        # 清理之前的构建
        cargo clean
        
        # 构建 Android 库
        cargo ndk \
            -t aarch64-linux-android \
            -t armv7-linux-androideabi \
            -t x86_64-linux-android \
            -t i686-linux-android \
            build --release
        
        echo '📱 复制库文件到 Android 项目...'
        
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
        
        echo '📱 构建 Android APK...'
        cd ../app
        
        # 构建 Debug APK
        ./gradlew assembleDebug
        
        # 构建 Release APK
        ./gradlew assembleRelease
        
        echo '📱 复制 APK 文件...'
        mkdir -p ../build/outputs
        cp build/outputs/apk/debug/app-debug.apk ../build/outputs/
        cp build/outputs/apk/release/app-release-unsigned.apk ../build/outputs/
        
        echo '✅ 构建完成！'
        echo '📁 APK 文件位置:'
        echo '   - Debug: build/outputs/app-debug.apk'
        echo '   - Release: build/outputs/app-release-unsigned.apk'
    "

# 显示构建结果
echo "🎉 Docker 构建完成！"
echo "📊 构建结果:"
ls -lh build/outputs/*.apk 2>/dev/null || echo "未找到 APK 文件"

echo "📱 现在您可以安装 APK 到 Android 设备进行测试"
