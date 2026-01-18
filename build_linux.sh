#!/bin/bash
# Build Moss Engine on Linux

BUILD_DIR="build-linux"
BUILD_TYPE="${1:-Release}"
TARGET="${2:-}"

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(Debug|Release|RelWithDebInfo|MinSizeRel)$ ]]; then
    echo "Invalid build type: $BUILD_TYPE"
    echo "Usage: $0 [Debug|Release|RelWithDebInfo|MinSizeRel] [target]"
    exit 1
fi

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Build directory not found. Run generate_linux.sh first."
    exit 1
fi

cd "$BUILD_DIR" || exit 1

# Build
BUILD_ARGS=("--build" "." "--config" "$BUILD_TYPE" "-j$(nproc)")

if [ -n "$TARGET" ]; then
    BUILD_ARGS+=("--target" "$TARGET")
fi

cmake "${BUILD_ARGS[@]}"

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Build completed successfully!"
    echo "========================================"
else
    echo ""
    echo "Build failed!"
    exit 1
fi

cd ..
