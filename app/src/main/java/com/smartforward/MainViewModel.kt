package com.smartforward

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class MainUiState(
    val isRunning: Boolean = false,
    val status: String = "已停止",
    val connections: Int = 0,
    val bytesTransferred: Long = 0,
    val uptime: String = "00:00:00",
    val logs: List<String> = emptyList(),
    val showLogs: Boolean = false
)

class MainViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(MainUiState())
    val uiState: StateFlow<MainUiState> = _uiState.asStateFlow()
    
    private val native = SmartForwardNative()
    private var startTime: Long = 0
    
    init {
        // 初始化日志系统
        native.initLogger()
        
        // 启动状态监控
        viewModelScope.launch {
            while (true) {
                updateStatus()
                delay(1000) // 每秒更新一次
            }
        }
    }
    
    fun toggleService() {
        if (_uiState.value.isRunning) {
            stopService()
        } else {
            startService()
        }
    }
    
    private fun startService() {
        viewModelScope.launch {
            try {
                val config = createDefaultConfig()
                val result = native.startProxy(config)
                
                if (result == 0) {
                    _uiState.value = _uiState.value.copy(
                        isRunning = true,
                        status = "运行中",
                        startTime = System.currentTimeMillis()
                    )
                    startTime = System.currentTimeMillis()
                    addLog("服务启动成功")
                } else {
                    addLog("服务启动失败，错误代码: $result")
                }
            } catch (e: Exception) {
                addLog("启动服务时发生错误: ${e.message}")
            }
        }
    }
    
    private fun stopService() {
        viewModelScope.launch {
            try {
                val result = native.stopProxy()
                
                if (result == 0) {
                    _uiState.value = _uiState.value.copy(
                        isRunning = false,
                        status = "已停止",
                        connections = 0,
                        bytesTransferred = 0,
                        uptime = "00:00:00"
                    )
                    addLog("服务已停止")
                } else {
                    addLog("停止服务失败，错误代码: $result")
                }
            } catch (e: Exception) {
                addLog("停止服务时发生错误: ${e.message}")
            }
        }
    }
    
    private fun updateStatus() {
        try {
            val status = native.getStatus()
            val isRunning = status == "running"
            
            if (isRunning && startTime > 0) {
                val uptimeMs = System.currentTimeMillis() - startTime
                val uptimeSeconds = uptimeMs / 1000
                val hours = uptimeSeconds / 3600
                val minutes = (uptimeSeconds % 3600) / 60
                val seconds = uptimeSeconds % 60
                val uptime = String.format("%02d:%02d:%02d", hours, minutes, seconds)
                
                _uiState.value = _uiState.value.copy(
                    isRunning = isRunning,
                    status = if (isRunning) "运行中" else "已停止",
                    uptime = uptime,
                    connections = (Math.random() * 10).toInt(), // 模拟连接数
                    bytesTransferred = (Math.random() * 1024 * 1024).toLong() // 模拟传输量
                )
            } else {
                _uiState.value = _uiState.value.copy(
                    isRunning = isRunning,
                    status = if (isRunning) "运行中" else "已停止"
                )
            }
        } catch (e: Exception) {
            // 忽略状态更新错误
        }
    }
    
    fun toggleLogs() {
        _uiState.value = _uiState.value.copy(
            showLogs = !_uiState.value.showLogs
        )
        
        if (_uiState.value.showLogs) {
            loadLogs()
        }
    }
    
    private fun loadLogs() {
        viewModelScope.launch {
            try {
                val logs = native.getLogs()
                val logList = logs.split("\n").filter { it.isNotEmpty() }
                _uiState.value = _uiState.value.copy(logs = logList)
            } catch (e: Exception) {
                addLog("加载日志失败: ${e.message}")
            }
        }
    }
    
    fun openConfig() {
        addLog("打开配置管理")
        // 这里可以导航到配置页面
    }
    
    fun openMonitor() {
        addLog("打开监控面板")
        // 这里可以导航到监控页面
    }
    
    private fun addLog(message: String) {
        val timestamp = java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.getDefault())
            .format(java.util.Date())
        val logEntry = "[$timestamp] $message"
        
        val currentLogs = _uiState.value.logs.toMutableList()
        currentLogs.add(logEntry)
        
        // 保持最新的20条日志
        if (currentLogs.size > 20) {
            currentLogs.removeAt(0)
        }
        
        _uiState.value = _uiState.value.copy(logs = currentLogs)
    }
    
    private fun createDefaultConfig(): String {
        return """
        {
            "server": {
                "host": "0.0.0.0",
                "port": 8080,
                "timeout": 30
            },
            "proxy": {
                "http_port": 8080,
                "https_port": 8443,
                "socks_port": 1080,
                "max_connections": 1000
            },
            "logging": {
                "level": "info",
                "file": null
            }
        }
        """.trimIndent()
    }
}
