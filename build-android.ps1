# Smart Forward Android 构建脚本 (WSL + Docker)
# 在 Windows PowerShell 中运行

Write-Host "🚀 开始构建 Smart Forward Android..." -ForegroundColor Green

# 检查WSL是否可用
try {
    wsl --version | Out-Null
    Write-Host "✅ WSL 可用" -ForegroundColor Green
} catch {
    Write-Host "❌ WSL 不可用，请先安装 WSL" -ForegroundColor Red
    exit 1
}

# 检查Docker是否在WSL中运行
Write-Host "🔍 检查 Docker 状态..." -ForegroundColor Yellow
$dockerStatus = wsl -e bash -c "docker info > /dev/null 2>&1 && echo 'running' || echo 'stopped'"

if ($dockerStatus -eq "stopped") {
    Write-Host "❌ Docker 未运行，正在启动..." -ForegroundColor Red
    wsl -e bash -c "sudo service docker start"
    Start-Sleep -Seconds 5
}

# 进入WSL并运行构建脚本
Write-Host "🔨 在 WSL 中运行构建..." -ForegroundColor Yellow
wsl -e bash -c "cd /mnt/d/Cursor/smart-forward-android && chmod +x scripts/docker-build.sh && ./scripts/docker-build.sh"

# 检查构建结果
if (Test-Path "build/outputs/app-debug.apk") {
    Write-Host "✅ 构建成功！" -ForegroundColor Green
    Write-Host "📱 APK 文件位置:" -ForegroundColor Cyan
    Write-Host "   - Debug: build/outputs/app-debug.apk" -ForegroundColor White
    Write-Host "   - Release: build/outputs/app-release-unsigned.apk" -ForegroundColor White
    
    # 显示文件大小
    $debugSize = (Get-Item "build/outputs/app-debug.apk").Length / 1MB
    $releaseSize = (Get-Item "build/outputs/app-release-unsigned.apk").Length / 1MB
    Write-Host "📊 文件大小:" -ForegroundColor Cyan
    Write-Host "   - Debug: $([math]::Round($debugSize, 2)) MB" -ForegroundColor White
    Write-Host "   - Release: $([math]::Round($releaseSize, 2)) MB" -ForegroundColor White
    
    Write-Host "`n🎉 构建完成！现在可以安装 APK 到 Android 设备进行测试" -ForegroundColor Green
} else {
    Write-Host "❌ 构建失败，请检查错误信息" -ForegroundColor Red
    exit 1
}
