# Smart Forward Android 构建测试脚本

Write-Host "🚀 开始测试 Smart Forward Android 构建..." -ForegroundColor Green

# 检查 Rust 环境
Write-Host "📋 检查 Rust 环境..." -ForegroundColor Yellow
try {
    $rustVersion = rustc --version
    Write-Host "✅ Rust 版本: $rustVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Rust 未安装，请先安装 Rust" -ForegroundColor Red
    exit 1
}

# 检查 cargo-ndk
Write-Host "📋 检查 cargo-ndk..." -ForegroundColor Yellow
try {
    $ndkVersion = cargo ndk --version
    Write-Host "✅ cargo-ndk 版本: $ndkVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ cargo-ndk 未安装，请运行: cargo install cargo-ndk" -ForegroundColor Red
    exit 1
}

# 检查 Android 目标
Write-Host "📋 检查 Android 目标..." -ForegroundColor Yellow
$targets = @("aarch64-linux-android", "armv7-linux-androideabi", "x86_64-linux-android", "i686-linux-android")
foreach ($target in $targets) {
    try {
        rustup target add $target
        Write-Host "✅ 目标 $target 已添加" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ 目标 $target 添加失败" -ForegroundColor Yellow
    }
}

# 测试 Rust 库构建
Write-Host "📦 测试 Rust 库构建..." -ForegroundColor Yellow
Set-Location rust-lib

try {
    cargo check
    Write-Host "✅ Rust 库检查通过" -ForegroundColor Green
} catch {
    Write-Host "❌ Rust 库检查失败" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# 测试 Android 目标构建
Write-Host "📱 测试 Android 目标构建..." -ForegroundColor Yellow
try {
    cargo ndk -t aarch64-linux-android build --release
    Write-Host "✅ Android 目标构建成功" -ForegroundColor Green
} catch {
    Write-Host "❌ Android 目标构建失败" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Set-Location ..

# 检查构建结果
Write-Host "📁 检查构建结果..." -ForegroundColor Yellow
$libPath = "rust-lib\target\aarch64-linux-android\release\libsmart_forward.so"
if (Test-Path $libPath) {
    $fileSize = (Get-Item $libPath).Length
    Write-Host "✅ 库文件已生成: $libPath ($fileSize bytes)" -ForegroundColor Green
} else {
    Write-Host "❌ 库文件未找到: $libPath" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 所有测试通过！Android 项目构建环境配置成功！" -ForegroundColor Green
Write-Host "📝 下一步: 在 Android Studio 中打开项目" -ForegroundColor Cyan
