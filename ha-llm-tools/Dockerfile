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
    openssh-client \
    ca-certificates \
    openssl \
    tmux

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

# Install Claude Code using official installer (skip on unsupported architectures)
ENV USE_BUILTIN_RIPGREP=0
RUN set -x && \
    if [ "${BUILD_ARCH}" != "armv7" ]; then \
        curl -fsSL https://claude.ai/install.sh | bash && \
        ln -sf /root/.local/bin/claude /usr/local/bin/claude; \
    else \
        echo "Claude Code not available for armv7, skipping installation"; \
        echo '#!/bin/sh\necho "Claude Code not available for armv7 architecture"' > /usr/local/bin/claude && \
        chmod +x /usr/local/bin/claude; \
    fi

# Copy root filesystem
COPY rootfs /

# Copy tmux config
COPY tmux.conf /root/.tmux.conf

# Make scripts executable
RUN chmod +x /usr/bin/start.sh /usr/bin/addonctl && \
    chmod +x /etc/services.d/llm/run