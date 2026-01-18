#!/bin/bash
# Generate build files for Linux

BUILD_DIR="build-linux"
BUILD_TYPE="${1:-Release}"

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(Debug|Release|RelWithDebInfo|MinSizeRel)$ ]]; then
    echo "Invalid build type: $BUILD_TYPE"
    echo "Usage: $0 [Debug|Release|RelWithDebInfo|MinSizeRel]"
    exit 1
fi

# Create build directory
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
fi

cd "$BUILD_DIR" || exit 1

# Generate build files
cmake .. -DCMAKE_BUILD_TYPE="$BUILD_TYPE"

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Linux build files generated successfully!"
    echo "Build type: $BUILD_TYPE"
    echo ""
    echo "To build, run: cmake --build ."
    echo "Or use: ../build_linux.sh"
    echo "========================================"
else
    echo ""
    echo "Failed to generate build files"
    echo "Make sure CMake and required dependencies are installed"
    exit 1
fi

cd ..
