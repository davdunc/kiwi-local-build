FROM fedora:latest

# Install dependencies
RUN dnf update -y && \
    dnf install -y \
    python3 \
    python3-pip \
    git \
    tar \
    gzip \
    wget \
    unzip \
    sudo \
    jq \
    awscli \
    && dnf clean all

# Install kiwi dependencies
RUN pip3 install --upgrade pip && \
    pip3 install \
    kiwi-ng \
    boto3 \
    awscli

# Set up working directory
WORKDIR /build

# Copy build scripts
COPY scripts/ /build/scripts/

# Make scripts executable
RUN chmod +x /build/scripts/*.sh

# Default command
ENTRYPOINT ["/build/scripts/build-image.sh"]
