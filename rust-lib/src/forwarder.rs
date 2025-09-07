use crate::config::Config;
use anyhow::Result;
use tokio::net::{TcpListener, TcpStream};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use std::sync::Arc;
use log::{info, error, warn};

pub struct SmartForwarder {
    config: Config,
    is_running: Arc<std::sync::atomic::AtomicBool>,
}

impl SmartForwarder {
    pub fn new(config: Config) -> Result<Self> {
        Ok(Self {
            config,
            is_running: Arc::new(std::sync::atomic::AtomicBool::new(false)),
        })
    }
    
    pub async fn run(&self) -> Result<()> {
        self.is_running.store(true, std::sync::atomic::Ordering::SeqCst);
        
        info!("Smart Forwarder 启动中...");
        info!("HTTP 代理端口: {}", self.config.proxy.http_port);
        info!("HTTPS 代理端口: {}", self.config.proxy.https_port);
        info!("SOCKS 代理端口: {}", self.config.proxy.socks_port);
        
        // 启动HTTP代理服务器
        let http_config = self.config.clone();
        let http_running = self.is_running.clone();
        tokio::spawn(async move {
            if let Err(e) = Self::start_http_proxy(http_config, http_running).await {
                error!("HTTP代理启动失败: {}", e);
            }
        });
        
        // 启动HTTPS代理服务器
        let https_config = self.config.clone();
        let https_running = self.is_running.clone();
        tokio::spawn(async move {
            if let Err(e) = Self::start_https_proxy(https_config, https_running).await {
                error!("HTTPS代理启动失败: {}", e);
            }
        });
        
        // 启动SOCKS代理服务器
        let socks_config = self.config.clone();
        let socks_running = self.is_running.clone();
        tokio::spawn(async move {
            if let Err(e) = Self::start_socks_proxy(socks_config, socks_running).await {
                error!("SOCKS代理启动失败: {}", e);
            }
        });
        
        // 保持运行
        while self.is_running.load(std::sync::atomic::Ordering::SeqCst) {
            tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
        }
        
        info!("Smart Forwarder 已停止");
        Ok(())
    }
    
    async fn start_http_proxy(
        config: Config,
        is_running: Arc<std::sync::atomic::AtomicBool>,
    ) -> Result<()> {
        let listener = TcpListener::bind(format!("0.0.0.0:{}", config.proxy.http_port)).await?;
        info!("HTTP代理服务器监听端口: {}", config.proxy.http_port);
        
        while is_running.load(std::sync::atomic::Ordering::SeqCst) {
            match listener.accept().await {
                Ok((stream, addr)) => {
                    info!("新的HTTP连接来自: {}", addr);
                    let config = config.clone();
                    let running = is_running.clone();
                    tokio::spawn(async move {
                        if let Err(e) = Self::handle_http_connection(stream, config).await {
                            warn!("处理HTTP连接失败: {}", e);
                        }
                    });
                }
                Err(e) => {
                    error!("接受HTTP连接失败: {}", e);
                }
            }
        }
        
        Ok(())
    }
    
    async fn start_https_proxy(
        config: Config,
        is_running: Arc<std::sync::atomic::AtomicBool>,
    ) -> Result<()> {
        let listener = TcpListener::bind(format!("0.0.0.0:{}", config.proxy.https_port)).await?;
        info!("HTTPS代理服务器监听端口: {}", config.proxy.https_port);
        
        while is_running.load(std::sync::atomic::Ordering::SeqCst) {
            match listener.accept().await {
                Ok((stream, addr)) => {
                    info!("新的HTTPS连接来自: {}", addr);
                    let config = config.clone();
                    let running = is_running.clone();
                    tokio::spawn(async move {
                        if let Err(e) = Self::handle_https_connection(stream, config).await {
                            warn!("处理HTTPS连接失败: {}", e);
                        }
                    });
                }
                Err(e) => {
                    error!("接受HTTPS连接失败: {}", e);
                }
            }
        }
        
        Ok(())
    }
    
    async fn start_socks_proxy(
        config: Config,
        is_running: Arc<std::sync::atomic::AtomicBool>,
    ) -> Result<()> {
        let listener = TcpListener::bind(format!("0.0.0.0:{}", config.proxy.socks_port)).await?;
        info!("SOCKS代理服务器监听端口: {}", config.proxy.socks_port);
        
        while is_running.load(std::sync::atomic::Ordering::SeqCst) {
            match listener.accept().await {
                Ok((stream, addr)) => {
                    info!("新的SOCKS连接来自: {}", addr);
                    let config = config.clone();
                    let running = is_running.clone();
                    tokio::spawn(async move {
                        if let Err(e) = Self::handle_socks_connection(stream, config).await {
                            warn!("处理SOCKS连接失败: {}", e);
                        }
                    });
                }
                Err(e) => {
                    error!("接受SOCKS连接失败: {}", e);
                }
            }
        }
        
        Ok(())
    }
    
    async fn handle_http_connection(mut stream: TcpStream, config: Config) -> Result<()> {
        let mut buffer = [0; 4096];
        let n = stream.read(&mut buffer).await?;
        
        if n == 0 {
            return Ok(());
        }
        
        let request = String::from_utf8_lossy(&buffer[..n]);
        info!("收到HTTP请求: {}", request.lines().next().unwrap_or(""));
        
        // 简单的HTTP响应
        let response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nSmart Forward HTTP Proxy is running!";
        stream.write_all(response.as_bytes()).await?;
        stream.flush().await?;
        
        Ok(())
    }
    
    async fn handle_https_connection(mut stream: TcpStream, config: Config) -> Result<()> {
        let mut buffer = [0; 4096];
        let n = stream.read(&mut buffer).await?;
        
        if n == 0 {
            return Ok(());
        }
        
        info!("收到HTTPS连接请求");
        
        // 简单的HTTPS响应（实际应用中需要TLS处理）
        let response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nSmart Forward HTTPS Proxy is running!";
        stream.write_all(response.as_bytes()).await?;
        stream.flush().await?;
        
        Ok(())
    }
    
    async fn handle_socks_connection(mut stream: TcpStream, config: Config) -> Result<()> {
        let mut buffer = [0; 4096];
        let n = stream.read(&mut buffer).await?;
        
        if n == 0 {
            return Ok(());
        }
        
        info!("收到SOCKS连接请求");
        
        // 简单的SOCKS响应（实际应用中需要完整的SOCKS协议处理）
        let response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nSmart Forward SOCKS Proxy is running!";
        stream.write_all(response.as_bytes()).await?;
        stream.flush().await?;
        
        Ok(())
    }
    
    pub fn stop(&self) {
        self.is_running.store(false, std::sync::atomic::Ordering::SeqCst);
    }
}
