use crate::config::Config;
use anyhow::Result;
use log::{info, error, warn};
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};

pub struct SmartForwarder {
    config: Config,
    is_running: Arc<AtomicBool>,
}

impl SmartForwarder {
    pub fn new(config: Config) -> Result<Self> {
        Ok(Self {
            config,
            is_running: Arc::new(AtomicBool::new(false)),
        })
    }
    
    pub async fn run(&self) -> Result<()> {
        self.is_running.store(true, Ordering::SeqCst);
        
        info!("Smart Forwarder 启动中...");
        info!("HTTP 代理端口: {}", self.config.proxy.http_port);
        info!("HTTPS 代理端口: {}", self.config.proxy.https_port);
        info!("SOCKS 代理端口: {}", self.config.proxy.socks_port);
        
        // 简化的代理服务器实现
        self.start_simple_proxy().await?;
        
        info!("Smart Forwarder 已停止");
        Ok(())
    }
    
    async fn start_simple_proxy(&self) -> Result<()> {
        use tokio::net::TcpListener;
        use tokio::io::{AsyncReadExt, AsyncWriteExt};
        
        // 启动HTTP代理
        let http_listener = TcpListener::bind(format!("0.0.0.0:{}", self.config.proxy.http_port)).await?;
        info!("HTTP代理服务器监听端口: {}", self.config.proxy.http_port);
        
        let is_running = self.is_running.clone();
        tokio::spawn(async move {
            loop {
                if !is_running.load(Ordering::SeqCst) {
                    break;
                }
                
                match http_listener.accept().await {
                    Ok((mut stream, addr)) => {
                        info!("新的HTTP连接来自: {}", addr);
                        
                        // 简单的HTTP响应
                        let response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nSmart Forward HTTP Proxy is running!";
                        if let Err(e) = stream.write_all(response.as_bytes()).await {
                            warn!("发送HTTP响应失败: {}", e);
                        }
                        if let Err(e) = stream.flush().await {
                            warn!("刷新HTTP流失败: {}", e);
                        }
                    }
                    Err(e) => {
                        error!("接受HTTP连接失败: {}", e);
                        tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
                    }
                }
            }
        });
        
        // 保持运行
        while self.is_running.load(Ordering::SeqCst) {
            tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
        }
        
        Ok(())
    }
    
    pub fn stop(&self) {
        self.is_running.store(false, Ordering::SeqCst);
    }
}