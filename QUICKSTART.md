# Smart Forward Android 快速开始

## 🚀 5分钟快速体验

### 1. 环境检查
```bash
# 检查 Rust 是否安装
rustc --version

# 检查 Android Studio 是否安装
android --version

# 检查 cargo-ndk 是否安装
cargo ndk --version
```

### 2. 克隆项目
```bash
# 克隆项目（如果已创建）
git clone https://github.com/your-username/smart-forward-android.git
cd smart-forward-android
```

### 3. 构建 Rust 库
```bash
# 构建 Android 库
./scripts/build-android.sh
```

### 4. 运行 Android 应用
```bash
# 在 Android Studio 中打开项目
# 连接 Android 设备或启动模拟器
# 点击 "Run" 按钮
```

## 📱 功能演示

### 1. 启动代理服务
1. 打开应用
2. 点击 "启动服务" 按钮
3. 观察状态变为 "运行中 🟢"

### 2. 配置转发规则
1. 点击 "配置管理" 按钮
2. 设置 HTTP 端口为 8080
3. 设置 HTTPS 端口为 8443
4. 添加目标服务器
5. 点击 "保存" 按钮

### 3. 监控服务状态
1. 点击 "监控面板" 按钮
2. 查看连接数统计
3. 查看数据传输量
4. 查看错误日志

## 🔧 开发模式

### 1. 修改 Rust 代码
```bash
# 编辑 Rust 代码
vim rust-lib/src/lib.rs

# 重新构建
./scripts/build-android.sh
```

### 2. 修改 Android 代码
```bash
# 在 Android Studio 中编辑
# 或者使用命令行
vim app/src/main/java/com/smartforward/MainActivity.kt
```

### 3. 调试应用
```bash
# 查看日志
adb logcat | grep SmartForward

# 查看设备信息
adb devices

# 安装应用
adb install app/build/outputs/apk/debug/app-debug.apk
```

## 📦 发布准备

### 1. 构建发布版本
```bash
# 构建 Release APK
./gradlew assembleRelease

# 签名 APK（需要配置签名）
./gradlew assembleRelease
```

### 2. 测试发布版本
```bash
# 安装发布版本
adb install app/build/outputs/apk/release/app-release.apk

# 测试功能
# 确保所有功能正常工作
```

### 3. 发布到应用商店
```bash
# 生成 AAB 文件（Google Play）
./gradlew bundleRelease

# 上传到 Google Play Console
# 或发布到 GitHub Releases
```

## 🆘 常见问题

### Q: 构建失败怎么办？
A: 检查环境配置，确保所有依赖都已安装

### Q: 应用崩溃怎么办？
A: 查看日志 `adb logcat`，检查 JNI 调用是否正确

### Q: 代理不工作怎么办？
A: 检查端口配置，确保目标服务器可访问

### Q: 如何添加新功能？
A: 先修改 Rust 库，再更新 Android 接口

## 📞 获取帮助

- **GitHub Issues**: 报告 Bug 和功能请求
- **文档**: 查看 `docs/` 目录下的详细文档
- **示例**: 查看 `examples/` 目录下的代码示例

---

**快速开始版本**: v1.0  
**最后更新**: 2024-12-19  
**状态**: 📋 计划阶段
