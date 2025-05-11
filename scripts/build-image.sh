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

# Find all kiwi.xml files in the repository
echo "Searching for kiwi.xml files containing the $IMAGE_PROFILE profile..."
XML_FILES=$(find "$REPO_DIR" -name "kiwi.xml")

# Initialize a variable to track if we found the profile
PROFILE_FOUND=false
PROFILE_XML=""

# Check each XML file for the profile
for XML_FILE in $XML_FILES; do
  # Check if the file contains the profile name
  if grep -q "<profile name=\"$IMAGE_PROFILE\"" "$XML_FILE"; then
    echo "Found profile $IMAGE_PROFILE in $XML_FILE"
    PROFILE_FOUND=true
    PROFILE_XML="$XML_FILE"
    break
  fi
done

# If profile not found, list available profiles
if [ "$PROFILE_FOUND" = false ]; then
  echo "Error: Could not find profile $IMAGE_PROFILE in any kiwi.xml file"
  echo "Available profiles:"
  for XML_FILE in $XML_FILES; do
    echo "In $XML_FILE:"
    grep -o "<profile name=\"[^\"]*\"" "$XML_FILE" | sed 's/<profile name="/  /' | sed 's/"//'
  done
  exit 1
fi

# Get the directory containing the XML file
CONFIG_DIR=$(dirname "$PROFILE_XML")
echo "Using configuration directory: $CONFIG_DIR"

# Create output directory for this image
IMAGE_OUTPUT="$OUTPUT_DIR/$BRANCH/$IMAGE_PROFILE"
mkdir -p "$IMAGE_OUTPUT"

echo "================================================"
echo "Building image: $IMAGE_PROFILE from $CONFIG_DIR"
echo "================================================"

# Run kiwi to build the image
kiwi-ng --type oem system build \
  --description "$CONFIG_DIR" \
  --target-dir "$IMAGE_OUTPUT" \
  --profile "$IMAGE_PROFILE"

echo "Image build complete: $IMAGE_PROFILE"
echo "Output saved to: $IMAGE_OUTPUT"

echo "Build complete for branch: $BRANCH"
echo "Output available in: $OUTPUT_DIR/$BRANCH"
