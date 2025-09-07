# Smart Forward Android 构建指南

## 🎯 构建方案选择

您有多种方式构建 Android 应用，无需在本地安装完整的 Android 开发环境：

### 方案一：WSL + Docker 构建 (推荐)
- ✅ 完全隔离的构建环境
- ✅ 无需安装 Android SDK/NDK
- ✅ 支持所有架构 (ARM64, ARMv7, x86_64, x86)
- ✅ 一键构建 APK

### 方案二：GitHub Actions 云端构建
- ✅ 完全云端构建
- ✅ 自动构建和发布
- ✅ 支持 CI/CD
- ✅ 无需本地环境

### 方案三：本地 Rust 构建 + Android Studio
- ⚠️ 需要 Android Studio
- ✅ 快速调试
- ✅ 完整开发环境

## 🚀 快速开始

### 方案一：WSL + Docker 构建

#### 1. 准备工作
```bash
# 确保 WSL 已安装并运行
wsl --version

# 确保 Docker 在 WSL 中运行
wsl -e bash -c "docker --version"
```

#### 2. 一键构建
```powershell
# 在 Windows PowerShell 中运行
.\build-android.ps1
```

#### 3. 手动构建 (WSL)
```bash
# 进入 WSL
wsl

# 进入项目目录
cd /mnt/d/Cursor/smart-forward-android

# 运行 Docker 构建
chmod +x scripts/docker-build.sh
./scripts/docker-build.sh
```

### 方案二：GitHub Actions 构建

#### 1. 推送代码到 GitHub
```bash
git add .
git commit -m "Add Android build support"
git push origin main
```

#### 2. 查看构建结果
- 进入 GitHub 仓库的 Actions 页面
- 查看构建日志和下载 APK 文件

### 方案三：本地构建

#### 1. 构建 Rust 库
```bash
# 在 WSL 中运行
chmod +x scripts/build-local.sh
./scripts/build-local.sh
```

#### 2. 使用 Android Studio
- 打开 Android Studio
- 导入项目
- 构建 APK

## 📱 构建结果

构建成功后，您将获得：

```
build/outputs/
├── app-debug.apk              # Debug 版本
└── app-release-unsigned.apk   # Release 版本 (未签名)
```

## 🔧 高级配置

### Docker 构建配置

如果需要修改构建环境，编辑 `Dockerfile`：

```dockerfile
# 修改 Android SDK 版本
ENV ANDROID_HOME=/opt/android-sdk

# 修改 NDK 版本
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/25.2.9519653
```

### GitHub Actions 配置

修改 `.github/workflows/android-build.yml` 来调整构建流程。

### 本地构建配置

修改 `scripts/build-local.sh` 来调整本地构建参数。

## 🐛 常见问题

### Q: Docker 构建失败怎么办？
A: 检查 Docker 是否运行，WSL 是否正常，网络连接是否正常。

### Q: GitHub Actions 构建失败？
A: 检查代码是否有语法错误，依赖是否正确配置。

### Q: 本地构建失败？
A: 确保 Rust 工具链已安装，Android 目标已添加。

### Q: APK 无法安装？
A: 检查设备是否允许安装未知来源的应用。

## 📊 构建性能

| 方案 | 首次构建时间 | 后续构建时间 | 环境要求 |
|------|-------------|-------------|----------|
| WSL + Docker | 10-15分钟 | 3-5分钟 | WSL + Docker |
| GitHub Actions | 8-12分钟 | 8-12分钟 | 无 |
| 本地构建 | 2-3分钟 | 30秒 | Rust + Android Studio |

## 🎉 下一步

构建完成后：

1. **测试应用**：安装 APK 到 Android 设备
2. **签名发布**：为 Release 版本添加签名
3. **发布应用**：上传到应用商店

## 📞 获取帮助

- **GitHub Issues**: 报告构建问题
- **文档**: 查看详细技术文档
- **示例**: 参考构建脚本示例

---

**构建指南版本**: v1.0  
**最后更新**: 2024-12-19  
**状态**: ✅ 可用
