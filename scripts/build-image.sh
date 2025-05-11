#!/bin/bash
set -e

# Default values
BRANCH="rawhide"
OUTPUT_DIR="/build/output"
REPO_DIR="/build/fedora-kiwi-descriptions"
IMAGE_PROFILE="Cloud-Base-AmazonEC2"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)
      BRANCH="$2"
      shift 2
      ;;
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

echo "Building kiwi image for branch: $BRANCH"
echo "Image profile: $IMAGE_PROFILE"
echo "Output directory: $OUTPUT_DIR"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Clone or update the repository
if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning fedora-kiwi-descriptions repository..."
  git clone https://pagure.io/fedora-kiwi-descriptions.git "$REPO_DIR"
else
  echo "Updating fedora-kiwi-descriptions repository..."
  cd "$REPO_DIR"
  git fetch --all
  cd -
fi

# Checkout the specified branch
cd "$REPO_DIR"
git checkout "$BRANCH" || { echo "Branch $BRANCH not found"; exit 1; }
git pull origin "$BRANCH"
cd -

# Create output directory for this image
IMAGE_OUTPUT="$OUTPUT_DIR/$BRANCH/$IMAGE_PROFILE"
mkdir -p "$IMAGE_OUTPUT"

echo "================================================"
echo "Building image: $IMAGE_PROFILE for branch: $BRANCH"
echo "================================================"

# Run kiwi to build the image - use the repository root as the description directory
# kiwi will find the appropriate XML and profile
kiwi --type oem system build \
  --description "$REPO_DIR" \
  --target-dir "$IMAGE_OUTPUT" \
  --profile "$IMAGE_PROFILE"

echo "Image build complete: $IMAGE_PROFILE"
echo "Output saved to: $IMAGE_OUTPUT"

echo "Build complete for branch: $BRANCH"
echo "Output available in: $OUTPUT_DIR/$BRANCH"
