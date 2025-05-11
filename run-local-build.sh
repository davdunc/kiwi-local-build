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

# Build the container image using podman
echo "Building container image for kiwi builds..."
podman build -t kiwi-fedora-builder:latest -f Containerfile .

# Run the container based on branch selection
if [ "$BRANCH" == "all" ]; then
  # Build all branches
  podman run --rm \
    --privileged \
    -v "$(pwd)/output:/build/output:Z" \
    kiwi-fedora-builder:latest \
    /build/scripts/build-all-branches.sh --output-dir /build/output --profile "$IMAGE_PROFILE"
else
  # Build specific branch
  podman run --rm \
    --privileged \
    -v "$(pwd)/output:/build/output:Z" \
    kiwi-fedora-builder:latest \
    /build/scripts/build-image.sh --branch "$BRANCH" --output-dir /build/output --profile "$IMAGE_PROFILE"
fi

echo "Build process complete! Output files are in $OUTPUT_DIR"
