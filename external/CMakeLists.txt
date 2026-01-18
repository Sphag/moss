set(CMAKE_FOLDER "external")

set(EXTERNAL_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# GLM - header-only library
# Repository: https://github.com/g-truc/glm
if(EXISTS ${EXTERNAL_DIR}/glm)
    add_library(glm INTERFACE)
    target_include_directories(glm INTERFACE ${EXTERNAL_DIR}/glm)
    message(STATUS "GLM: ${EXTERNAL_DIR}/glm")
else()
    message(WARNING "GLM not found in ${EXTERNAL_DIR}/glm")
    message(WARNING "  Run: git submodule add https://github.com/g-truc/glm.git external/glm")
endif()

# Volk - Vulkan loader
# Repository: https://github.com/zeux/volk
if(EXISTS ${EXTERNAL_DIR}/volk)
    if(EXISTS ${EXTERNAL_DIR}/volk/CMakeLists.txt)
        add_subdirectory(${EXTERNAL_DIR}/volk volk_build)
        message(STATUS "Volk: ${EXTERNAL_DIR}/volk")
    else()
        # Volk might not have CMakeLists.txt, create a simple interface target
        add_library(volk INTERFACE)
        target_include_directories(volk INTERFACE ${EXTERNAL_DIR}/volk)
        message(STATUS "Volk: ${EXTERNAL_DIR}/volk (using interface target)")
    endif()
else()
    message(WARNING "Volk not found in ${EXTERNAL_DIR}/volk")
    message(WARNING "  Run: git submodule add https://github.com/zeux/volk.git external/volk")
endif()

# Vulkan Memory Allocator - header-only
# Repository: https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
if(EXISTS ${EXTERNAL_DIR}/vulkan-memory-allocator)
    add_library(vma INTERFACE)
    target_include_directories(vma INTERFACE ${EXTERNAL_DIR}/vulkan-memory-allocator/include)
    target_link_libraries(vma INTERFACE Vulkan::Vulkan)
    message(STATUS "VMA: ${EXTERNAL_DIR}/vulkan-memory-allocator")
else()
    message(WARNING "Vulkan Memory Allocator not found")
    message(WARNING "  Run: git submodule add https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git external/vulkan-memory-allocator")
endif()

# D3D12 Memory Allocator - header-only (Windows only)
# Repository: https://github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator
if(MOSS_PLATFORM_WINDOWS)
    if(EXISTS ${EXTERNAL_DIR}/D3D12MemoryAllocator)
        add_library(D3D12MemoryAllocator INTERFACE)
        target_include_directories(D3D12MemoryAllocator INTERFACE 
            ${EXTERNAL_DIR}/D3D12MemoryAllocator/src
        )
        message(STATUS "D3D12MA: ${EXTERNAL_DIR}/D3D12MemoryAllocator")
    else()
        message(WARNING "D3D12 Memory Allocator not found")
        message(WARNING "  Run: git submodule add https://github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator.git external/D3D12MemoryAllocator")
    endif()
endif()

# ImGui - needs to be built
# Repository: https://github.com/ocornut/imgui
if(EXISTS ${EXTERNAL_DIR}/imgui)
    set(IMGUI_DIR ${EXTERNAL_DIR}/imgui)
    
    # ImGui core source files
    file(GLOB IMGUI_CORE_SOURCES
        "${IMGUI_DIR}/*.cpp"
        "${IMGUI_DIR}/*.h"
    )
    
    add_library(imgui STATIC ${IMGUI_CORE_SOURCES})
    target_include_directories(imgui PUBLIC ${IMGUI_DIR})
    
    # Suppress warnings for external library
    moss_suppress_compiler_warnings(imgui)
    
    # Platform-specific backend files
    if(MOSS_PLATFORM_WINDOWS)
        if(EXISTS ${IMGUI_DIR}/backends/imgui_impl_win32.cpp)
            target_sources(imgui PRIVATE
                ${IMGUI_DIR}/backends/imgui_impl_win32.cpp
                ${IMGUI_DIR}/backends/imgui_impl_win32.h
            )
        endif()
        if(EXISTS ${IMGUI_DIR}/backends/imgui_impl_vulkan.cpp)
            target_sources(imgui PRIVATE
                ${IMGUI_DIR}/backends/imgui_impl_vulkan.cpp
                ${IMGUI_DIR}/backends/imgui_impl_vulkan.h
            )
        endif()
        if(EXISTS ${IMGUI_DIR}/backends/imgui_impl_dx12.cpp)
            target_sources(imgui PRIVATE
                ${IMGUI_DIR}/backends/imgui_impl_dx12.cpp
                ${IMGUI_DIR}/backends/imgui_impl_dx12.h
            )
        endif()
    elseif(MOSS_PLATFORM_LINUX)
        if(EXISTS ${IMGUI_DIR}/backends/imgui_impl_x11.cpp)
            target_sources(imgui PRIVATE
                ${IMGUI_DIR}/backends/imgui_impl_x11.cpp
                ${IMGUI_DIR}/backends/imgui_impl_x11.h
            )
        endif()
        if(EXISTS ${IMGUI_DIR}/backends/imgui_impl_vulkan.cpp)
            target_sources(imgui PRIVATE
                ${IMGUI_DIR}/backends/imgui_impl_vulkan.cpp
                ${IMGUI_DIR}/backends/imgui_impl_vulkan.h
            )
        endif()
        target_link_libraries(imgui PUBLIC ${X11_LIBRARIES})
        target_include_directories(imgui PUBLIC ${X11_INCLUDE_DIRS})
    endif()
    
    target_link_libraries(imgui PUBLIC Vulkan::Vulkan)
    
    message(STATUS "ImGui: ${EXTERNAL_DIR}/imgui")
else()
    message(WARNING "ImGui not found in ${EXTERNAL_DIR}/imgui")
    message(WARNING "  Run: git submodule add -b docking https://github.com/ocornut/imgui.git external/imgui")
endif()

# DXC - using prebuilt version since compiling is pain in the ass
# Currently using this version https://github.com/microsoft/DirectXShaderCompiler/releases/tag/v1.8.2505.1
if(MOSS_PLATFORM_WINDOWS)
    set(DXC_EXE_PATH  ${EXTERNAL_DIR}/dxc/windows/bin/x64 CACHE PATH "Path to the DXC bin")
    set(DXC_LIB_PATH  ${EXTERNAL_DIR}/dxc/windows/lib/x64 CACHE PATH "Path to the DXC lib")
    set(DXC_INCLUDE_DIR ${EXTERNAL_DIR}/dxc/windows/include CACHE PATH "Path to the DXC include")
else()
    set(DXC_EXE_PATH  ${EXTERNAL_DIR}/dxc/linux/bin/x64 CACHE PATH "Path to the DXC bin")
    set(DXC_LIB_PATH  ${EXTERNAL_DIR}/dxc/linux/lib/x64 CACHE PATH "Path to the DXC lib")
    set(DXC_INCLUDE_DIR ${EXTERNAL_DIR}/dxc/linux/include CACHE PATH "Path to the DXC include")
endif()

message(STATUS "DXC: ${EXTERNAL_DIR}/dxc")

add_library(dxcompiler SHARED IMPORTED GLOBAL)
set_target_properties(dxcompiler PROPERTIES
    IMPORTED_LOCATION "${DXC_BIN_PATH}/dxcompiler.dll"
    IMPORTED_IMPLIB   "${DXC_LIB_PATH}/dxcompiler.lib"
)
target_include_directories(dxcompiler INTERFACE "${DXC_INCLUDE_DIR}")


# GoogleTest - only needed for tests
# Repository: https://github.com/google/googletest
if(MOSS_BUILD_TESTS)
    if(EXISTS ${EXTERNAL_DIR}/googletest)
        if(EXISTS ${EXTERNAL_DIR}/googletest/CMakeLists.txt)
            add_subdirectory(${EXTERNAL_DIR}/googletest googletest_build)
            
            # Suppress warnings for GoogleTest targets (external library)
            if(TARGET gtest)
                moss_suppress_compiler_warnings(gtest)
            endif()
            if(TARGET gtest_main)
                moss_suppress_compiler_warnings(gtest_main)
            endif()
            if(TARGET gmock)
                moss_suppress_compiler_warnings(gmock)
            endif()
            if(TARGET gmock_main)
                moss_suppress_compiler_warnings(gmock_main)
            endif()
            
            message(STATUS "GoogleTest: ${EXTERNAL_DIR}/googletest")
        else()
            message(WARNING "GoogleTest found but no CMakeLists.txt")
        endif()
    else()
        message(WARNING "GoogleTest not found in ${EXTERNAL_DIR}/googletest")
        message(WARNING "  Run: git submodule add https://github.com/google/googletest.git external/googletest")
    endif()
endif()

message(STATUS "")
message(STATUS "=== External Libraries Status ===")

set(CMAKE_FOLDER "")
