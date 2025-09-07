# 🚀 Smart Forward Android 快速开始

## 📱 项目概述

这是一个基于Rust核心的Android网络转发应用，支持智能流量转发和代理功能。**完全不需要在本地安装Android开发环境！**

## 🎯 三种构建方式

### 方式一：GitHub Actions 云端构建 (推荐) ⭐

**最简单的方式，完全云端构建！**

#### 1. 推送代码到GitHub
```bash
# 添加远程仓库（替换为您的仓库地址）
git remote add origin https://github.com/your-username/smart-forward-android.git

# 推送到GitHub
git push -u origin main
```

#### 2. 查看构建结果
1. 进入GitHub仓库的 "Actions" 页面
2. 查看构建状态和日志
3. 下载构建好的APK文件

#### 3. 手动触发构建
- 进入 "Actions" 页面
- 选择 "Android Build" 或 "Quick Build Test"
- 点击 "Run workflow"

### 方式二：WSL + Docker 构建

**适合本地开发，需要WSL和Docker**

#### 1. 确保环境
```bash
# 检查WSL
wsl --version

# 检查Docker
wsl -e bash -c "docker --version"
```

#### 2. 一键构建
```powershell
# 在Windows PowerShell中运行
.\build-android.ps1
```

### 方式三：本地Rust构建

**仅构建Rust库，需要Android Studio完成APK构建**

```bash
# 在WSL中运行
chmod +x scripts/build-local.sh
./scripts/build-local.sh
```

## 📋 项目结构

```
smart-forward-android/
├── .github/workflows/          # GitHub Actions 工作流
│   ├── android-build.yml       # 完整构建
│   └── quick-build.yml         # 快速构建
├── app/                        # Android 应用
│   ├── src/main/java/          # Kotlin 代码
│   └── src/main/jniLibs/       # Rust 编译的 .so 文件
├── rust-lib/                   # Rust 核心库
│   ├── src/lib.rs              # 核心代码
│   └── src/jni_interface.rs    # JNI 接口
├── scripts/                    # 构建脚本
│   ├── docker-build.sh         # Docker 构建
│   └── build-local.sh          # 本地构建
├── Dockerfile                  # Docker 环境
├── build-android.ps1           # Windows 构建脚本
└── test-github-actions.ps1     # 测试脚本
```

## 🔧 快速测试

### 1. 验证配置
```powershell
# 运行测试脚本
.\test-github-actions.ps1
```

### 2. 检查文件
确保以下文件存在：
- ✅ `.github/workflows/android-build.yml`
- ✅ `app/build.gradle`
- ✅ `rust-lib/Cargo.toml`
- ✅ `gradlew`

## 📱 构建结果

构建成功后，您将获得：

```
app/build/outputs/apk/
├── debug/app-debug.apk              # Debug 版本
└── release/app-release-unsigned.apk # Release 版本 (未签名)
```

## 🎯 下一步操作

### 1. 推送代码
```bash
git add .
git commit -m "Add Android build support"
git push origin main
```

### 2. 查看构建
- 进入GitHub仓库
- 点击 "Actions" 标签
- 查看构建状态

### 3. 下载APK
- 在构建结果页面下载APK
- 安装到Android设备测试

## 🐛 常见问题

### Q: GitHub Actions构建失败？
A: 检查代码是否有语法错误，查看构建日志

### Q: Docker构建失败？
A: 确保Docker在WSL中正常运行

### Q: APK无法安装？
A: 检查设备是否允许安装未知来源的应用

### Q: 如何修改配置？
A: 编辑 `rust-lib/config.yaml.example` 或 `app/build.gradle`

## 📚 详细文档

- **GitHub Actions指南**: `GITHUB-ACTIONS-GUIDE.md`
- **完整构建指南**: `BUILD-GUIDE.md`
- **技术实现文档**: `docs/technical-implementation.md`

## 🎉 开始使用

1. **选择构建方式** (推荐GitHub Actions)
2. **推送代码到GitHub**
3. **查看构建结果**
4. **下载并安装APK**

---

**快速开始版本**: v1.0  
**最后更新**: 2024-12-19  
**状态**: ✅ 可用
