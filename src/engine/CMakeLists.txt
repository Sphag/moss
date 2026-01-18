# Engine Library
add_library(engine STATIC)

# Source files
# Note: Add your actual source files here as you develop
file(GLOB_RECURSE ENGINE_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/core/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/core/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/core/*.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/rhi/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/rhi/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/rhi/*.hpp"
)

target_sources(engine PRIVATE ${ENGINE_SOURCES})

# Include directories
target_include_directories(engine
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/core
        ${CMAKE_CURRENT_SOURCE_DIR}/rhi
)

# Dependencies
target_link_libraries(engine
    PUBLIC
        Vulkan::Vulkan
        glm
        volk
        vma
        dxcompiler
)

# Platform-specific dependencies
if(MOSS_PLATFORM_WINDOWS)
    target_link_libraries(engine
        PUBLIC
            D3D12MemoryAllocator
            d3d12_headers
    )
    # Windows libraries
    target_link_libraries(engine
        PRIVATE
            d3d12.lib
            dxgi.lib
    )
endif()

# Compile definitions
target_compile_definitions(engine
    PUBLIC
        MOSS_ENGINE_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
        MOSS_ENGINE_VERSION_MINOR=${PROJECT_VERSION_MINOR}
        MOSS_ENGINE_VERSION_PATCH=${PROJECT_VERSION_PATCH}
)

# Compiler-specific options - apply strict warnings
moss_apply_compiler_warnings(engine)

# Installation (optional)
install(TARGETS engine
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    DESTINATION include/engine
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
)
