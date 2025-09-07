use jni::JNIEnv;
use jni::objects::{JClass, JString};
use jni::sys::{jint, jstring};
use std::sync::{Arc, Mutex};
use std::thread;
use tokio::runtime::Runtime;

use crate::config::Config;
use crate::forwarder::SmartForwarder;

// 全局状态管理
static mut RUNTIME: Option<Arc<Mutex<Option<Runtime>>>> = None;
static mut FORWARDER: Option<Arc<Mutex<Option<SmartForwarder>>>> = None;
static mut IS_RUNNING: bool = false;

// 初始化全局状态
fn init_globals() {
    unsafe {
        if RUNTIME.is_none() {
            RUNTIME = Some(Arc::new(Mutex::new(None)));
        }
        if FORWARDER.is_none() {
            FORWARDER = Some(Arc::new(Mutex::new(None)));
        }
    }
}

// 启动代理服务
#[no_mangle]
pub extern "system" fn Java_com_smartforward_SmartForwardNative_startProxy(
    env: JNIEnv,
    _class: JClass,
    config_json: JString,
) -> jint {
    init_globals();
    
    // 获取配置字符串
    let config_str: String = match env.get_string(&config_json) {
        Ok(s) => s.into(),
        Err(_) => return -1,
    };
    
    // 解析配置
    let config: Config = match serde_json::from_str(&config_str) {
        Ok(c) => c,
        Err(e) => {
            log::error!("配置解析失败: {}", e);
            return -2;
        }
    };
    
    unsafe {
        if IS_RUNNING {
            log::warn!("代理服务已在运行");
            return 0;
        }
        
        // 创建新的运行时
        let rt = match Runtime::new() {
            Ok(runtime) => runtime,
            Err(e) => {
                log::error!("创建运行时失败: {}", e);
                return -3;
            }
        };
        
        // 创建转发器
        let forwarder = match SmartForwarder::new(config) {
            Ok(f) => f,
            Err(e) => {
                log::error!("创建转发器失败: {}", e);
                return -4;
            }
        };
        
        // 启动转发器
        let forwarder_arc = Arc::new(Mutex::new(Some(forwarder)));
        let forwarder_clone = forwarder_arc.clone();
        
        thread::spawn(move || {
            rt.block_on(async {
                if let Ok(mut f) = forwarder_clone.lock() {
                    if let Some(forwarder) = f.take() {
                        if let Err(e) = forwarder.run().await {
                            log::error!("转发器运行失败: {}", e);
                        }
                    }
                }
            });
        });
        
        // 保存状态
        if let Ok(mut runtime) = RUNTIME.as_ref().unwrap().lock() {
            *runtime = Some(rt);
        }
        if let Ok(mut forwarder) = FORWARDER.as_ref().unwrap().lock() {
            *forwarder = Some(forwarder_arc);
        }
        
        IS_RUNNING = true;
        log::info!("代理服务启动成功");
        0
    }
}

// 停止代理服务
#[no_mangle]
pub extern "system" fn Java_com_smartforward_SmartForwardNative_stopProxy(
    _env: JNIEnv,
    _class: JClass,
) -> jint {
    unsafe {
        if !IS_RUNNING {
            log::warn!("代理服务未运行");
            return 0;
        }
        
        // 清理状态
        if let Ok(mut runtime) = RUNTIME.as_ref().unwrap().lock() {
            *runtime = None;
        }
        if let Ok(mut forwarder) = FORWARDER.as_ref().unwrap().lock() {
            *forwarder = None;
        }
        
        IS_RUNNING = false;
        log::info!("代理服务已停止");
        0
    }
}

// 获取服务状态
#[no_mangle]
pub extern "system" fn Java_com_smartforward_SmartForwardNative_getStatus(
    env: JNIEnv,
    _class: JClass,
) -> jstring {
    unsafe {
        let status = if IS_RUNNING {
            "running"
        } else {
            "stopped"
        };
        
        match env.new_string(status) {
            Ok(s) => s.into_raw(),
            Err(_) => std::ptr::null_mut(),
        }
    }
}

// 获取日志
#[no_mangle]
pub extern "system" fn Java_com_smartforward_SmartForwardNative_getLogs(
    env: JNIEnv,
    _class: JClass,
) -> jstring {
    // 这里可以实现日志收集逻辑
    // 暂时返回简单的状态信息
    let logs = if unsafe { IS_RUNNING } {
        "代理服务运行中...\n"
    } else {
        "代理服务已停止\n"
    };
    
    match env.new_string(logs) {
        Ok(s) => s.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

// 更新配置
#[no_mangle]
pub extern "system" fn Java_com_smartforward_SmartForwardNative_updateConfig(
    env: JNIEnv,
    _class: JClass,
    config_json: JString,
) -> jint {
    // 如果服务正在运行，需要重启
    unsafe {
        if IS_RUNNING {
            log::info!("服务运行中，需要重启以应用新配置");
            return 1; // 需要重启
        }
    }
    
    // 验证配置
    let config_str: String = match env.get_string(&config_json) {
        Ok(s) => s.into(),
        Err(_) => return -1,
    };
    
    match serde_json::from_str::<Config>(&config_str) {
        Ok(_) => {
            log::info!("配置验证成功");
            0
        }
        Err(e) => {
            log::error!("配置验证失败: {}", e);
            -2
        }
    }
}

// 初始化日志
#[no_mangle]
pub extern "system" fn Java_com_smartforward_SmartForwardNative_initLogger(
    _env: JNIEnv,
    _class: JClass,
) -> jint {
    #[cfg(target_os = "android")]
    {
        android_logger::init_once(
            android_logger::Config::default()
                .with_max_level(log::LevelFilter::Info)
                .with_tag("SmartForward"),
        );
    }
    
    #[cfg(not(target_os = "android"))]
    {
        env_logger::init();
    }
    
    log::info!("日志系统初始化完成");
    0
}
