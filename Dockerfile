FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_NDK_HOME=/opt/android-ndk \
    PATH=\"${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator\"

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# 安装Rust工具链
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=\"${PATH}:/root/.cargo/bin\"

# 安装Android SDK命令行工具
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && cd ${ANDROID_HOME}/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip -q commandlinetools-linux-9477386_latest.zip \
    && mv cmdline-tools latest \
    && rm commandlinetools-linux-9477386_latest.zip

# 安装Android平台和构建工具
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "ndk;25.2.9519653" \
    "platform-tools"

# 设置Android NDK路径
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/25.2.9519653

# 安装Rust Android目标
RUN rustup target add aarch64-linux-android \
    && rustup target add armv7-linux-androideabi \
    && rustup target add x86_64-linux-android \
    && rustup target add i686-linux-android

# 安装cargo-ndk
RUN cargo install cargo-ndk

# 创建工作目录
WORKDIR /workspace

# 设置默认命令
CMD ["/bin/bash"]
