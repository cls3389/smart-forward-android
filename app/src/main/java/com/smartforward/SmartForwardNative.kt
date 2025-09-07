package com.smartforward

/**
 * Smart Forward Native 接口
 * 通过 JNI 调用 Rust 核心库
 */
class SmartForwardNative {
    
    companion object {
        // 加载原生库
        init {
            System.loadLibrary("smart_forward")
        }
    }
    
    /**
     * 初始化日志系统
     * @return 0 成功，其他值失败
     */
    external fun initLogger(): Int
    
    /**
     * 启动代理服务
     * @param configJson 配置 JSON 字符串
     * @return 0 成功，其他值失败
     */
    external fun startProxy(configJson: String): Int
    
    /**
     * 停止代理服务
     * @return 0 成功，其他值失败
     */
    external fun stopProxy(): Int
    
    /**
     * 获取服务状态
     * @return 状态字符串 ("running" 或 "stopped")
     */
    external fun getStatus(): String
    
    /**
     * 获取日志信息
     * @return 日志字符串
     */
    external fun getLogs(): String
    
    /**
     * 更新配置
     * @param configJson 新配置 JSON 字符串
     * @return 0 成功，1 需要重启，其他值失败
     */
    external fun updateConfig(configJson: String): Int
}
