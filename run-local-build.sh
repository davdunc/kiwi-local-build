#!/bin/bash
set -e

# Default values
OUTPUT_DIR="$(pwd)/output"
IMAGE_PROFILE="Cloud-Base-AmazonEC2"
BRANCH="all"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --profile)
      IMAGE_PROFILE="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check SELinux status
echo "Checking SELinux status..."
SELINUX_STATUS=$(getenforce 2>/dev/null || echo "Unknown")

if [ "$SELINUX_STATUS" == "Enforcing" ]; then
  echo "ERROR: SELinux is in Enforcing mode. Kiwi builds will fail."
  echo "Please set SELinux to Permissive mode with: sudo setenforce 0"
  echo "To make this change permanent, edit /etc/selinux/config and set SELINUX=permissive"
  echo "After changing SELinux mode, run this script again."
  exit 1
elif [ "$SELINUX_STATUS" == "Permissive" ]; then
  echo "SELinux is in Permissive mode. This is suitable for kiwi builds."
elif [ "$SELINUX_STATUS" == "Disabled" ]; then
  echo "SELinux is Disabled. This is suitable for kiwi builds."
else
  echo "WARNING: Could not determine SELinux status. If the build fails, ensure SELinux is in Permissive mode."
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if user has sudo privileges
if ! command -v sudo &> /dev/null; then
  echo "ERROR: sudo is required to run privileged containers but is not installed."
  exit 1
fi

# Build the container image using podman with sudo
echo "Building container image for kiwi builds..."
sudo podman build -t kiwi-fedora-builder:latest -f Containerfile .

# Run the container based on branch selection
if [ "$BRANCH" == "all" ]; then
  # Build all branches
  echo "Building images for all branches (rawhide, f41, f42)..."
  sudo podman run --rm \
    --privileged \
    -v /dev:/dev \
    -v "$(pwd)/output:/build/output:Z" \
    --entrypoint /bin/bash \
    kiwi-fedora-builder:latest \
    -c "/build/scripts/build-all-branches.sh --output-dir /build/output --profile '$IMAGE_PROFILE'"
else
  # Build specific branch
  echo "Building image for branch: $BRANCH"
  sudo podman run --rm \
    --privileged \
    -v /dev:/dev \
    -v "$(pwd)/output:/build/output:Z" \
    --entrypoint /bin/bash \
    kiwi-fedora-builder:latest \
    -c "/build/scripts/build-image.sh --branch '$BRANCH' --output-dir /build/output --profile '$IMAGE_PROFILE'"
fi

# Fix permissions on output directory since it was created by root
echo "Fixing permissions on output directory..."
sudo chown -R $(id -u):$(id -g) "$OUTPUT_DIR"

echo "Build process complete! Output files are in $OUTPUT_DIR"
