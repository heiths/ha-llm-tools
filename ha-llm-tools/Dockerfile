ARG BUILD_FROM
FROM $BUILD_FROM

# Install system dependencies
RUN apk add --no-cache \
    libgcc \
    libstdc++ \
    curl \
    bash \
    jq \
    ripgrep \
    git \
    openssh-client

# Install yq (static binary)
ARG BUILD_ARCH
ARG YQ_VERSION=4.44.6
RUN set -x && \
    case "${BUILD_ARCH}" in \
        aarch64) YQ_ARCH="arm64" ;; \
        amd64) YQ_ARCH="amd64" ;; \
        armv7) YQ_ARCH="arm" ;; \
        *) echo "Unsupported arch: ${BUILD_ARCH}"; exit 1 ;; \
    esac && \
    curl -sSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${YQ_ARCH}" -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Install Claude Code using official installer
ENV USE_BUILTIN_RIPGREP=0
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    ln -sf /root/.local/bin/claude /usr/local/bin/claude

# Copy root filesystem
COPY rootfs /

# Make scripts executable
RUN chmod +x /usr/bin/start.sh /usr/bin/addonctl