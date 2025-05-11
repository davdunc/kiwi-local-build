#!/bin/bash
set -e

# Default values
OUTPUT_DIR="$(pwd)/output"
IMAGE_PROFILE="Cloud-Base-AmazonEC2"

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
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Build for each branch
for BRANCH in "rawhide" "f41" "f42"; do
  echo "=========================================================="
  echo "Starting build for branch: $BRANCH"
  echo "=========================================================="
  
  ./scripts/build-image.sh --branch "$BRANCH" --output-dir "$OUTPUT_DIR" --profile "$IMAGE_PROFILE"
  
  echo "Completed build for branch: $BRANCH"
  echo ""
done

echo "All branch builds complete!"
echo "Output available in: $OUTPUT_DIR"
