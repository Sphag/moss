# Building Moss Engine

## Prerequisites

- CMake 3.20 or higher
- C++20 compatible compiler
- Visual Studio 2026/2022 (Windows) or GCC/Clang (Linux)
- Vulkan SDK
- Windows SDK (Windows, for D3D12 support)

## Quick Start

### Windows - Visual Studio 2026
```bash
generate_vs2026.bat
# Then open build-vs2026\MossEngine.sln
```

### Windows - Visual Studio 2022
```bash
generate_vs2022.bat
# Then open build-vs2022\MossEngine.sln
```

### Windows - Clang
```bash
generate_windows_clang.bat
build_windows_clang.bat
```

### Linux
```bash
chmod +x generate_linux.sh build_linux.sh
./generate_linux.sh
./build_linux.sh
```

## Generating Build Files

### Visual Studio 2026 (Windows)

#### Using Command Line

```bash
# Create build directory
mkdir build-vs2026
cd build-vs2026

# Generate Visual Studio 2026 project files
cmake .. -G "Visual Studio 18 2026" -A x64

# Or for x86 (32-bit)
cmake .. -G "Visual Studio 18 2026" -A Win32
```

#### Using Helper Scripts

**Batch file:**
```bash
generate_vs2026.bat
```

**PowerShell:**
```powershell
.\generate_vs2026.ps1
```

#### Opening in Visual Studio

After generating, open `build-vs2026\MossEngine.sln` in Visual Studio 2026.

### Linux

#### Using Helper Scripts

**Generate build files:**
```bash
chmod +x generate_linux.sh build_linux.sh
./generate_linux.sh [Debug|Release|RelWithDebInfo|MinSizeRel]
```

**Build:**
```bash
./build_linux.sh [Debug|Release|RelWithDebInfo|MinSizeRel] [target]
```

#### Manual Build

```bash
mkdir build-linux
cd build-linux
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)
```

### Windows with Clang

#### Using Helper Scripts

**Generate build files:**
```bash
generate_windows_clang.bat [Debug|Release|RelWithDebInfo]
# Or PowerShell:
.\generate_windows_clang.ps1 -BuildType Release
```

**Build:**
```bash
build_windows_clang.bat [Debug|Release|RelWithDebInfo] [target]
# Or PowerShell:
.\build_windows_clang.ps1 -BuildType Release -Target engine
```

#### Manual Build

```bash
mkdir build-windows-clang
cd build-windows-clang
cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cmake --build .
```

**Note:** Requires Clang and Ninja to be installed and in PATH.

## Build Options

### CMake Options

- `MOSS_BUILD_TESTS` - Build tests (default: OFF)
  ```bash
  cmake .. -DMOSS_BUILD_TESTS=ON
  ```

- `MOSS_WARNINGS_AS_ERRORS` - Treat warnings as errors (default: ON)
  ```bash
  cmake .. -DMOSS_WARNINGS_AS_ERRORS=OFF  # Disable warnings as errors
  ```

- `CMAKE_BUILD_TYPE` - Build type (Release, Debug, RelWithDebInfo, MinSizeRel)
  ```bash
  cmake .. -DCMAKE_BUILD_TYPE=Debug
  ```

### Visual Studio Specific

When using Visual Studio generator, you can specify:
- Architecture: `-A x64` or `-A Win32` or `-A ARM64`
- Toolset: `-T v143` (VS2022) or `-T v144` (VS2026, if available)

Example:
```bash
cmake .. -G "Visual Studio 18 2026" -A x64 -T v144
```

## Building

### From Command Line

```bash
# After generating project files
cmake --build . --config Release

# Or build specific target
cmake --build . --config Debug --target engine
```

### From Visual Studio

1. Open `MossEngine.sln`
2. Select configuration (Debug/Release) from dropdown
3. Build → Build Solution (F7)

## Available Targets

- `engine` - Core engine library
- `sandbox` - Sample application
- `editor` - Visual editor
- `example_tool` - Example CLI tool
- `engine_tests` - Engine tests (if `MOSS_BUILD_TESTS=ON`)
- `example_tool_tests` - Tool tests (if `MOSS_BUILD_TESTS=ON`)

## External Dependencies

All external dependencies are expected to be git submodules in the `external/` directory:

```bash
# Initialize submodules
git submodule update --init --recursive
```

Required submodules:
- `external/dxc` - DirectX Shader Compiler (required, builds from source)
- `external/glm` - OpenGL Mathematics
- `external/volk` - Vulkan loader
- `external/vulkan-memory-allocator` - VMA
- `external/D3D12MemoryAllocator` - D3D12MA (Windows only)
- `external/imgui` - Dear ImGui
- `external/googletest` - Google Test (optional, for tests)

## Troubleshooting

### DXC Build Fails

DXC requires LLVM to build. Make sure:
1. LLVM is installed and available in PATH
2. Or use a pre-built DXC (not recommended, as we use a specific version)

### Visual Studio Generator Not Found

Make sure Visual Studio 2026 or 2022 is installed. Check available generators:
```bash
cmake --help
```

### Vulkan Not Found

Install Vulkan SDK and make sure it's in PATH, or set `VULKAN_SDK` environment variable.

### Clang Not Found (Windows)

1. Install LLVM/Clang from https://llvm.org/builds/
2. Add Clang to PATH, or specify full path in CMake
3. Make sure Ninja is installed: https://ninja-build.org/

### Linux Build Issues

- Make sure development packages are installed:
  ```bash
  # Ubuntu/Debian
  sudo apt-get install build-essential cmake libx11-dev libvulkan-dev
  
  # Fedora
  sudo dnf install gcc-c++ cmake libX11-devel vulkan-devel
  ```

### Permission Denied (Linux Scripts)

Make scripts executable:
```bash
chmod +x generate_linux.sh build_linux.sh
```
