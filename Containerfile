FROM fedora:latest

# Install kiwi and dependencies
RUN dnf update -y && \
    dnf install -y \
    kiwi \
    git \
    tar \
    gzip \
    qemu-img \
    dosfstools \
    e2fsprogs \
    xz \
    jq \
    wget \
    curl \
    python3-pip \
    shadow-utils \
    && dnf clean all

# Install additional tools that might be needed
RUN dnf install -y \
    createrepo \
    rpm-build \
    mock \
    && dnf clean all

# Set up working directory
WORKDIR /build

# Copy build scripts
COPY scripts/ /build/scripts/

# Make scripts executable
RUN chmod +x /build/scripts/*.sh

# Default command
ENTRYPOINT ["/build/scripts/build-image.sh"]
