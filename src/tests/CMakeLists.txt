# Tests
if(NOT MOSS_BUILD_TESTS)
    return()
endif()

set(CMAKE_FOLDER "tests")

# Test executable
add_executable(engine_tests
    core_tests.cpp
)

target_include_directories(engine_tests
    PRIVATE
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/external/googletest/googletest/include
)

target_link_libraries(engine_tests
    PRIVATE
        engine
        GTest::gtest
        GTest::gtest_main
        GTest::gmock
)

# Platform-specific libraries for tests
if(MOSS_PLATFORM_LINUX)
    target_link_libraries(engine_tests
        PRIVATE
            pthread
    )
endif()

# Apply strict compiler warnings
moss_apply_compiler_warnings(engine_tests)

# Register tests
include(GoogleTest)
gtest_discover_tests(engine_tests)

message(STATUS "Tests enabled")

set(CMAKE_FOLDER "")
