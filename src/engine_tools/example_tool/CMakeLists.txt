# Example CLI Tool
# This is a template for creating CLI tools for the Moss Engine

add_executable(example_tool
    main.cpp
)

target_include_directories(example_tool
    PRIVATE
        ${CMAKE_SOURCE_DIR}/src
)

target_link_libraries(example_tool
    PRIVATE
        engine
)

# Apply strict compiler warnings
moss_apply_compiler_warnings(example_tool)

# Platform-specific link libraries
if(MOSS_PLATFORM_LINUX)
    target_link_libraries(example_tool
        PRIVATE
            pthread
    )
endif()

# Tests for example_tool
if(MOSS_BUILD_TESTS)
    add_executable(example_tool_tests
        tests/example_tool_tests.cpp
    )
    
    target_include_directories(example_tool_tests
        PRIVATE
            ${CMAKE_SOURCE_DIR}/src
            ${CMAKE_SOURCE_DIR}/external/googletest/googletest/include
    )
    
    target_link_libraries(example_tool_tests
        PRIVATE
            engine
            GTest::gtest
            GTest::gtest_main
            GTest::gmock
    )
    
    # Apply strict compiler warnings
    moss_apply_compiler_warnings(example_tool_tests)
    
    if(MOSS_PLATFORM_LINUX)
        target_link_libraries(example_tool_tests
            PRIVATE
                pthread
        )
    endif()
    
    # Register tests
    include(GoogleTest)
    gtest_discover_tests(example_tool_tests)
endif()
