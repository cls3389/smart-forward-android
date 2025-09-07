# GitHub Actions 云端构建指南

## 🚀 快速开始

### 1. 推送代码到GitHub

```bash
# 初始化Git仓库（如果还没有）
git init

# 添加所有文件
git add .

# 提交更改
git commit -m "Add Android build support with GitHub Actions"

# 添加远程仓库（替换为您的仓库地址）
git remote add origin https://github.com/your-username/smart-forward-android.git

# 推送到GitHub
git push -u origin main
```

### 2. 查看构建结果

1. 进入您的GitHub仓库页面
2. 点击 "Actions" 标签页
3. 查看构建状态和日志
4. 下载构建好的APK文件

## 📋 构建工作流说明

### 完整构建 (android-build.yml)
- **触发条件**: 推送到 main/develop 分支，PR，手动触发
- **构建目标**: 所有Android架构 (ARM64, ARMv7, x86_64, x86)
- **输出**: Debug APK + Release APK
- **构建时间**: 约8-12分钟

### 快速构建 (quick-build.yml)
- **触发条件**: 推送到 main 分支，手动触发
- **构建目标**: 仅ARM架构 (ARM64, ARMv7)
- **输出**: Debug APK
- **构建时间**: 约5-8分钟

## 🔧 手动触发构建

### 方法一：通过GitHub网页
1. 进入仓库的 "Actions" 页面
2. 选择 "Android Build" 或 "Quick Build Test"
3. 点击 "Run workflow" 按钮
4. 选择分支并点击 "Run workflow"

### 方法二：通过API
```bash
# 使用GitHub CLI
gh workflow run android-build.yml

# 或使用curl
curl -X POST \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/your-username/smart-forward-android/actions/workflows/android-build.yml/dispatches \
  -d '{"ref":"main"}'
```

## 📱 下载APK文件

### 从构建结果下载
1. 进入构建详情页面
2. 滚动到 "Artifacts" 部分
3. 点击下载链接

### 从Releases下载
如果配置了自动发布，APK会自动上传到Releases页面。

## 🐛 常见问题解决

### 构建失败 - Rust编译错误
```yaml
# 检查Rust版本和依赖
- name: Check Rust version
  run: rustc --version
```

### 构建失败 - Android SDK问题
```yaml
# 确保Android SDK正确安装
- name: Set up Android SDK
  uses: android-actions/setup-android@v3
  with:
    api-level: 34
    build-tools: 34.0.0
```

### 构建失败 - Gradle问题
```yaml
# 检查Gradle版本
- name: Check Gradle version
  run: ./gradlew --version
```

## 🔄 自动发布配置

### 创建Release工作流
```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      
    - name: Download APK
      uses: actions/download-artifact@v3
      with:
        name: smart-forward-release
        
    - name: Create Release
      uses: actions/create-release@v1
      with:
        tag_name: ${{ github.ref }}
        release_name: Release ${{ github.ref }}
        files: app-release-unsigned.apk
```

## 📊 构建状态徽章

在README中添加构建状态徽章：

```markdown
![Android Build](https://github.com/your-username/smart-forward-android/workflows/Android%20Build/badge.svg)
```

## 🎯 优化建议

### 1. 缓存优化
```yaml
- name: Cache Gradle dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
```

### 2. 并行构建
```yaml
strategy:
  matrix:
    target: [aarch64-linux-android, armv7-linux-androideabi, x86_64-linux-android, i686-linux-android]
```

### 3. 条件构建
```yaml
- name: Build only if Rust files changed
  if: contains(github.event.head_commit.modified, 'rust-lib/')
  run: cargo build
```

## 📞 获取帮助

- **GitHub Issues**: 报告构建问题
- **Actions日志**: 查看详细构建日志
- **社区支持**: 参考GitHub Actions文档

---

**GitHub Actions指南版本**: v1.0  
**最后更新**: 2024-12-19  
**状态**: ✅ 可用
