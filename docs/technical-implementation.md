# Smart Forward Android 技术实现文档

## 🏗️ 技术架构详解

### 1. 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Android 应用层                            │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (Jetpack Compose)                                │
│  ├── MainActivity.kt                                       │
│  ├── ConfigActivity.kt                                     │
│  └── MonitorActivity.kt                                    │
├─────────────────────────────────────────────────────────────┤
│  Service Layer (Android Services)                          │
│  ├── SmartForwardService.kt                                │
│  ├── ProxyService.kt                                       │
│  └── NotificationService.kt                                │
├─────────────────────────────────────────────────────────────┤
│  JNI Layer (Native Interface)                              │
│  ├── SmartForwardNative.kt                                 │
│  └── JNI 调用接口                                           │
├─────────────────────────────────────────────────────────────┤
│  Rust Core Layer (Native Library)                          │
│  ├── libsmart_forward.so (aarch64)                         │
│  ├── libsmart_forward.so (armv7)                           │
│  └── libsmart_forward.so (x86_64)                          │
└─────────────────────────────────────────────────────────────┘
```

### 2. 核心组件

#### 2.1 Rust 核心库
```rust
// rust-lib/src/lib.rs
use jni::JNIEnv;
use jni::objects::{JClass, JString};
use jni::sys::jstring;

#[no_mangle]
pub extern "system" fn Java_com_smartforward_SmartForwardNative_startProxy(
    env: JNIEnv,
    _class: JClass,
    config: JString,
) -> jint {
    // 启动代理服务
    let config_str: String = env.get_string(config).unwrap().into();
    match start_proxy_service(&config_str) {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

#[no_mangle]
pub extern "system" fn Java_com_smartforward_SmartForwardNative_stopProxy(
    _env: JNIEnv,
    _class: JClass,
) -> jint {
    // 停止代理服务
    match stop_proxy_service() {
        Ok(_) => 0,
        Err(_) => -1,
    }
}
```

#### 2.2 Android 服务层
```kotlin
// app/src/main/java/com/smartforward/SmartForwardService.kt
class SmartForwardService : Service() {
    private val native = SmartForwardNative()
    private var isRunning = false
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startProxy()
            ACTION_STOP -> stopProxy()
        }
        return START_STICKY
    }
    
    private fun startProxy() {
        val config = loadConfig()
        val result = native.startProxy(config)
        isRunning = result == 0
        updateNotification()
    }
    
    private fun stopProxy() {
        native.stopProxy()
        isRunning = false
        updateNotification()
    }
}
```

#### 2.3 UI 层
```kotlin
// app/src/main/java/com/smartforward/MainActivity.kt
@Composable
fun MainScreen() {
    val service = remember { SmartForwardService() }
    var isRunning by remember { mutableStateOf(false) }
    
    Column {
        // 服务状态
        ServiceStatusCard(isRunning = isRunning)
        
        // 控制按钮
        ControlButtons(
            isRunning = isRunning,
            onStart = { service.startProxy() },
            onStop = { service.stopProxy() }
        )
        
        // 配置入口
        ConfigButton { /* 打开配置界面 */ }
        
        // 监控入口
        MonitorButton { /* 打开监控界面 */ }
    }
}
```

## 🔧 实现细节

### 1. 端口配置策略

#### 1.1 端口映射
```yaml
# 配置文件示例
proxy:
  http:
    listen_port: 8080
    target_port: 80
  https:
    listen_port: 8443
    target_port: 443
  socks:
    listen_port: 1080
    target_port: 1080
```

#### 1.2 端口重定向
```kotlin
// 端口重定向逻辑
fun redirectPort(originalPort: Int): Int {
    return when (originalPort) {
        80 -> 8080
        443 -> 8443
        1080 -> 1080
        else -> originalPort
    }
}
```

### 2. 权限管理

#### 2.1 AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 网络权限 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- 存储权限 -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <!-- 前台服务权限 -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    
    <application>
        <!-- 主活动 -->
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        
        <!-- 代理服务 -->
        <service
            android:name=".SmartForwardService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="dataSync" />
    </application>
</manifest>
```

### 3. 配置管理

#### 3.1 配置文件结构
```kotlin
// 配置数据类
data class ProxyConfig(
    val http: HttpConfig,
    val https: HttpsConfig,
    val socks: SocksConfig,
    val targets: List<TargetConfig>
)

data class HttpConfig(
    val enabled: Boolean = true,
    val listenPort: Int = 8080,
    val bufferSize: Int = 4096
)

data class TargetConfig(
    val host: String,
    val port: Int,
    val priority: Int = 1,
    val healthCheck: Boolean = true
)
```

#### 3.2 配置持久化
```kotlin
// 配置管理器
class ConfigManager(private val context: Context) {
    private val prefs = context.getSharedPreferences("smart_forward", Context.MODE_PRIVATE)
    
    fun saveConfig(config: ProxyConfig) {
        val json = Gson().toJson(config)
        prefs.edit().putString("config", json).apply()
    }
    
    fun loadConfig(): ProxyConfig? {
        val json = prefs.getString("config", null) ?: return null
        return try {
            Gson().fromJson(json, ProxyConfig::class.java)
        } catch (e: Exception) {
            null
        }
    }
}
```

### 4. 状态监控

#### 4.1 状态数据
```kotlin
data class ServiceStatus(
    val isRunning: Boolean = false,
    val startTime: Long = 0,
    val connections: Int = 0,
    val bytesTransferred: Long = 0,
    val errorCount: Int = 0
)
```

#### 4.2 状态更新
```kotlin
// 状态管理器
class StatusManager {
    private val _status = MutableStateFlow(ServiceStatus())
    val status = _status.asStateFlow()
    
    fun updateStatus(newStatus: ServiceStatus) {
        _status.value = newStatus
    }
    
    fun updateConnections(count: Int) {
        _status.value = _status.value.copy(connections = count)
    }
}
```

## 🚀 构建配置

### 1. Rust 构建配置

#### 1.1 Cargo.toml
```toml
[package]
name = "smart-forward-lib"
version = "0.1.0"
edition = "2021"

[lib]
name = "smart_forward"
crate-type = ["cdylib"]

[dependencies]
jni = "0.21"
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_yaml = "0.9"
log = "0.4"
env_logger = "0.10"

[target.'cfg(target_os = "android")'.dependencies]
android_logger = "0.13"
```

#### 1.2 构建脚本
```bash
#!/bin/bash
# build-android.sh

# 设置 Android 目标
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android

# 编译 Android 库
cargo ndk -t aarch64-linux-android -t armv7-linux-androideabi -t x86_64-linux-android build --release

# 复制到 Android 项目
cp target/aarch64-linux-android/release/libsmart_forward.so app/src/main/jniLibs/arm64-v8a/
cp target/armv7-linux-androideabi/release/libsmart_forward.so app/src/main/jniLibs/armeabi-v7a/
cp target/x86_64-linux-android/release/libsmart_forward.so app/src/main/jniLibs/x86_64/
```

### 2. Android 构建配置

#### 2.1 build.gradle (Module: app)
```gradle
android {
    compileSdk 34
    
    defaultConfig {
        applicationId "com.smartforward"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            isMinifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = '1.8'
    }
    
    buildFeatures {
        compose true
    }
    
    composeOptions {
        kotlinCompilerExtensionVersion '1.5.4'
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
    implementation 'androidx.activity:activity-compose:1.8.2'
    implementation 'androidx.compose.ui:ui:1.5.4'
    implementation 'androidx.compose.ui:ui-tooling-preview:1.5.4'
    implementation 'androidx.compose.material3:material3:1.1.2'
    implementation 'androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0'
    implementation 'com.google.code.gson:gson:2.10.1'
}
```

## 📱 用户界面设计

### 1. 主界面布局
```
┌─────────────────────────────────────┐
│  Smart Forward                [⚙️]  │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐ │
│  │  服务状态: 运行中 🟢            │ │
│  │  连接数: 5                      │ │
│  │  运行时间: 2小时30分            │ │
│  └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐ │
│  │  [启动服务] [停止服务]          │ │
│  └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐ │
│  │  [配置管理] [监控面板] [日志]   │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 2. 配置界面
```
┌─────────────────────────────────────┐
│  ← 配置管理                    [保存] │
├─────────────────────────────────────┤
│  HTTP 代理                          │
│  ┌─────────────────────────────────┐ │
│  │  启用: [✓] 端口: [8080]         │ │
│  └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│  HTTPS 代理                         │
│  ┌─────────────────────────────────┐ │
│  │  启用: [✓] 端口: [8443]         │ │
│  └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│  目标服务器                          │
│  ┌─────────────────────────────────┐ │
│  │  服务器1: [192.168.1.100:443]  │ │
│  │  服务器2: [backup.com:443]     │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## 🔍 测试策略

### 1. 单元测试
```kotlin
class SmartForwardServiceTest {
    @Test
    fun testStartProxy() {
        val service = SmartForwardService()
        val result = service.startProxy()
        assertTrue(result == 0)
    }
    
    @Test
    fun testStopProxy() {
        val service = SmartForwardService()
        service.startProxy()
        val result = service.stopProxy()
        assertTrue(result == 0)
    }
}
```

### 2. 集成测试
```kotlin
class ProxyIntegrationTest {
    @Test
    fun testHttpProxy() {
        // 启动代理服务
        val service = SmartForwardService()
        service.startProxy()
        
        // 测试 HTTP 请求
        val response = testHttpRequest("http://127.0.0.1:8080")
        assertTrue(response.isSuccessful)
        
        // 停止服务
        service.stopProxy()
    }
}
```

### 3. 性能测试
```kotlin
class PerformanceTest {
    @Test
    fun testMemoryUsage() {
        val service = SmartForwardService()
        val initialMemory = getMemoryUsage()
        
        service.startProxy()
        val afterStartMemory = getMemoryUsage()
        
        // 内存使用应该合理
        assertTrue(afterStartMemory - initialMemory < 50 * 1024 * 1024) // 50MB
    }
}
```

---

**文档版本**: v1.0  
**最后更新**: 2024-12-19  
**状态**: 📋 计划阶段
