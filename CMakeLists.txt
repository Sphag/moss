cmake_minimum_required(VERSION 3.20)

project(MossEngine 
    VERSION 1.0.0
    DESCRIPTION "Moss Game Engine"
    LANGUAGES CXX C
)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Platform detection
if(WIN32)
    set(MOSS_PLATFORM_WINDOWS ON)
    set(MOSS_PLATFORM_NAME "Windows")
    message(STATUS "Platform: Windows")
elseif(UNIX AND NOT APPLE)
    set(MOSS_PLATFORM_LINUX ON)
    set(MOSS_PLATFORM_NAME "Linux")
    message(STATUS "Platform: Linux")
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

# Build configuration
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Include custom CMake modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Include compiler warnings configuration
include(cmake/CompilerWarnings.cmake)

# Platform-specific settings
if(MOSS_PLATFORM_WINDOWS)
    # Windows-specific flags
    add_compile_definitions(MOSS_PLATFORM_WINDOWS)
    add_compile_definitions(NOMINMAX)  # Disable Windows min/max macros
    add_compile_definitions(WIN32_LEAN_AND_MEAN)
    
    # Use Unicode on Windows
    add_compile_definitions(UNICODE)
    add_compile_definitions(_UNICODE)
    
    # Set Windows SDK version (can be overridden)
    if(NOT CMAKE_SYSTEM_VERSION)
        set(CMAKE_SYSTEM_VERSION 10.0)
    endif()
    
    # D3D12 is part of Windows SDK
    add_compile_definitions(MOSS_D3D12_ENABLED)
elseif(MOSS_PLATFORM_LINUX)
    # Linux-specific flags
    add_compile_definitions(MOSS_PLATFORM_LINUX)
    
    # X11 and other Linux libraries
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(X11 REQUIRED x11)
endif()

# Find Vulkan
find_package(Vulkan REQUIRED)
if(Vulkan_FOUND)
    message(STATUS "Vulkan found: ${Vulkan_INCLUDE_DIRS}")
    add_compile_definitions(MOSS_VULKAN_ENABLED)
else()
    message(FATAL_ERROR "Vulkan not found")
endif()

# Find D3D12 and DXGI (Windows only)
if(MOSS_PLATFORM_WINDOWS)

    # 1. Look for the Windows SDK Root in the Registry
    get_filename_component(WIN_SDK_ROOT
        "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot10]"
        ABSOLUTE
    )

    if(NOT WIN_SDK_ROOT OR NOT EXISTS "${WIN_SDK_ROOT}")
        set(WIN_SDK_ROOT "C:/Program Files (x86)/Windows Kits/10")
    endif()

    # 2. Find the latest installed version (e.g., 10.0.xxxxx.0)
    file(GLOB SDK_VERSIONS 
        RELATIVE "${WIN_SDK_ROOT}/Include" 
        "${WIN_SDK_ROOT}/Include/10.*"
    )

    if(SDK_VERSIONS)
        # Sort descending to get the newest version at index 0
        list(SORT SDK_VERSIONS ORDER DESCENDING)
        list(GET SDK_VERSIONS 0 LATEST_SDK_VERSION)
        
        message(STATUS "Found Windows SDK: ${LATEST_SDK_VERSION}")
        
        set(SDK_INC_PATH "${WIN_SDK_ROOT}/Include/${LATEST_SDK_VERSION}")
    else()
        message(FATAL_ERROR "Could not find any Windows 10/11 SDK versions at ${WIN_SDK_ROOT}")
    endif()

    # Find D3D12 headers
    set(D3D12_INCLUDE_DIR "${SDK_INC_PATH}")
    
    # Create interface target for D3D12/DXGI includes
    if(D3D12_INCLUDE_DIR)
        add_library(d3d12_headers INTERFACE)
        target_include_directories(d3d12_headers INTERFACE ${D3D12_INCLUDE_DIR} ${DXGI_INCLUDE_DIR})
        message(STATUS "D3D12 found: ${D3D12_INCLUDE_DIR}")
    else()
        message(WARNING "D3D12 headers not found. D3D12 support may be limited.")
    endif()
endif()

# External libraries - configured in external/CMakeLists.txt
# All external libraries are assumed to be git submodules/repos
set(EXTERNAL_DIR ${CMAKE_SOURCE_DIR}/external)

# Option to build tests (needed before external/CMakeLists.txt for googletest)
option(MOSS_BUILD_TESTS "Build tests" OFF)
if(MOSS_BUILD_TESTS)
    enable_testing()
endif()

# Configure external libraries
add_subdirectory(${EXTERNAL_DIR} external_build)

# Add source directories
add_subdirectory(src/engine)
add_subdirectory(src/sandbox)
add_subdirectory(src/editor)
add_subdirectory(src/engine_tools)

# Optional tests
if(MOSS_BUILD_TESTS)
    add_subdirectory(src/tests)
endif()

# Include shader compilation
include(cmake/ShaderCompilation.cmake)

message(STATUS "")
message(STATUS "=== Moss Engine Configuration ===")
message(STATUS "Platform: ${MOSS_PLATFORM_NAME}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Vulkan: ${Vulkan_FOUND}")
if(MOSS_PLATFORM_WINDOWS)
    message(STATUS "D3D12: Enabled")
endif()
message(STATUS "Tests: ${MOSS_BUILD_TESTS}")
message(STATUS "================================")
message(STATUS "")
