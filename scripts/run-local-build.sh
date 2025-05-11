#!/bin/bash
set -e

# Default values
CONFIG_DIR="$(pwd)/config"
OUTPUT_DIR="$(pwd)/output"
IMAGE_NAME="kiwi-image"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --config-dir)
      CONFIG_DIR="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --image-name)
      IMAGE_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Build the Docker image
echo "Building Docker image for kiwi builds..."
docker build -t kiwi-builder:latest ./docker/

# Run the container to build the kiwi image
echo "Running kiwi build in container..."
docker run --rm \
  -v "$CONFIG_DIR:/build/config:ro" \
  -v "$OUTPUT_DIR:/build/output" \
  kiwi-builder:latest \
  --config /build/config \
  --output-dir /build/output \
  --image-name "$IMAGE_NAME"

echo "Build complete! Output files are in $OUTPUT_DIR"
