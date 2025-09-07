use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConnectionInfo {
    pub id: String,
    pub local_addr: String,
    pub remote_addr: String,
    pub protocol: String,
    pub bytes_sent: u64,
    pub bytes_received: u64,
    pub start_time: chrono::DateTime<chrono::Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProxyStats {
    pub total_connections: u64,
    pub active_connections: u64,
    pub total_bytes_sent: u64,
    pub total_bytes_received: u64,
    pub uptime_seconds: u64,
}

impl Default for ProxyStats {
    fn default() -> Self {
        Self {
            total_connections: 0,
            active_connections: 0,
            total_bytes_sent: 0,
            total_bytes_received: 0,
            uptime_seconds: 0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProxyConfig {
    pub name: String,
    pub enabled: bool,
    pub port: u16,
    pub max_connections: usize,
    pub timeout_seconds: u64,
}

impl Default for ProxyConfig {
    fn default() -> Self {
        Self {
            name: "default".to_string(),
            enabled: true,
            port: 8080,
            max_connections: 1000,
            timeout_seconds: 30,
        }
    }
}
