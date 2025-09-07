# GitHub Actions 测试脚本
# 用于验证GitHub Actions配置是否正确

Write-Host "🚀 测试 GitHub Actions 配置..." -ForegroundColor Green

# 检查Git仓库状态
Write-Host "`n📋 检查Git仓库状态..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  有未提交的更改:" -ForegroundColor Yellow
    Write-Host $gitStatus -ForegroundColor White
    Write-Host "`n建议先提交更改:" -ForegroundColor Cyan
    Write-Host "git add ." -ForegroundColor White
    Write-Host "git commit -m 'Add GitHub Actions support'" -ForegroundColor White
} else {
    Write-Host "✅ Git仓库状态正常" -ForegroundColor Green
}

# 检查GitHub Actions文件
Write-Host "`n📁 检查GitHub Actions文件..." -ForegroundColor Yellow
if (Test-Path ".github/workflows/android-build.yml") {
    Write-Host "✅ .github/workflows/android-build.yml 存在" -ForegroundColor Green
} else {
    Write-Host "❌ .github/workflows/android-build.yml 不存在" -ForegroundColor Red
}

if (Test-Path ".github/workflows/quick-build.yml") {
    Write-Host "✅ .github/workflows/quick-build.yml 存在" -ForegroundColor Green
} else {
    Write-Host "❌ .github/workflows/quick-build.yml 不存在" -ForegroundColor Red
}

# 检查Android项目文件
Write-Host "`n📱 检查Android项目文件..." -ForegroundColor Yellow
if (Test-Path "app/build.gradle") {
    Write-Host "✅ app/build.gradle 存在" -ForegroundColor Green
} else {
    Write-Host "❌ app/build.gradle 不存在" -ForegroundColor Red
}

if (Test-Path "build.gradle") {
    Write-Host "✅ build.gradle 存在" -ForegroundColor Green
} else {
    Write-Host "❌ build.gradle 不存在" -ForegroundColor Red
}

if (Test-Path "gradlew") {
    Write-Host "✅ gradlew 存在" -ForegroundColor Green
} else {
    Write-Host "❌ gradlew 不存在" -ForegroundColor Red
}

# 检查Rust项目文件
Write-Host "`n🦀 检查Rust项目文件..." -ForegroundColor Yellow
if (Test-Path "rust-lib/Cargo.toml") {
    Write-Host "✅ rust-lib/Cargo.toml 存在" -ForegroundColor Green
} else {
    Write-Host "❌ rust-lib/Cargo.toml 不存在" -ForegroundColor Red
}

if (Test-Path "rust-lib/src/lib.rs") {
    Write-Host "✅ rust-lib/src/lib.rs 存在" -ForegroundColor Green
} else {
    Write-Host "❌ rust-lib/src/lib.rs 不存在" -ForegroundColor Red
}

# 检查远程仓库
Write-Host "`n🌐 检查远程仓库..." -ForegroundColor Yellow
try {
    $remoteUrl = git remote get-url origin
    Write-Host "✅ 远程仓库: $remoteUrl" -ForegroundColor Green
    
    # 检查是否是GitHub仓库
    if ($remoteUrl -like "*github.com*") {
        Write-Host "✅ 这是GitHub仓库" -ForegroundColor Green
    } else {
        Write-Host "⚠️  这不是GitHub仓库，GitHub Actions可能无法工作" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ 没有配置远程仓库" -ForegroundColor Red
    Write-Host "请先添加远程仓库:" -ForegroundColor Cyan
    Write-Host "git remote add origin https://github.com/your-username/smart-forward-android.git" -ForegroundColor White
}

# 提供下一步建议
Write-Host "`n🎯 下一步操作建议:" -ForegroundColor Cyan
Write-Host "1. 提交所有更改到Git" -ForegroundColor White
Write-Host "2. 推送到GitHub仓库" -ForegroundColor White
Write-Host "3. 在GitHub上查看Actions页面" -ForegroundColor White
Write-Host "4. 手动触发构建测试" -ForegroundColor White

Write-Host "`n📚 参考文档:" -ForegroundColor Cyan
Write-Host "- GitHub Actions指南: GITHUB-ACTIONS-GUIDE.md" -ForegroundColor White
Write-Host "- 构建指南: BUILD-GUIDE.md" -ForegroundColor White

Write-Host "`n🎉 检查完成！" -ForegroundColor Green