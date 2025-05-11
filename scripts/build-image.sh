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

# Look specifically for the Cloud-Base-AmazonEC2 profile in the oem directory
OEM_DIR=$(find "$REPO_DIR" -path "*/oem/*/kiwi.xml" -exec dirname {} \; | grep -i "Cloud-Base-AmazonEC2" || true)

if [ -z "$OEM_DIR" ]; then
  # If not found directly, look for any directory that might contain this profile
  echo "Searching for $IMAGE_PROFILE profile in oem directories..."
  OEM_DIRS=$(find "$REPO_DIR" -path "*/oem/*/kiwi.xml" -exec dirname {} \;)
  
  for DIR in $OEM_DIRS; do
    if grep -q "$IMAGE_PROFILE" "$DIR/kiwi.xml"; then
      OEM_DIR="$DIR"
      break
    fi
  done
fi

if [ -z "$OEM_DIR" ]; then
  echo "Error: Could not find $IMAGE_PROFILE profile in oem directories"
  exit 1
fi

echo "================================================"
echo "Building image: $IMAGE_PROFILE from $OEM_DIR"
echo "================================================"

# Create output directory for this image
IMAGE_OUTPUT="$OUTPUT_DIR/$BRANCH/$IMAGE_PROFILE"
mkdir -p "$IMAGE_OUTPUT"

# Run kiwi to build the image
kiwi-ng --type oem system build \
  --description "$OEM_DIR" \
  --target-dir "$IMAGE_OUTPUT" \
  --profile "$IMAGE_PROFILE"

echo "Image build complete: $IMAGE_PROFILE"
echo "Output saved to: $IMAGE_OUTPUT"

echo "Build complete for branch: $BRANCH"
echo "Output available in: $OUTPUT_DIR/$BRANCH"
