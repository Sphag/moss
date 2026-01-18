# Sandbox executable - sample application using the Engine
add_executable(sandbox
    main.cpp
)

target_include_directories(sandbox
    PRIVATE
        ${CMAKE_SOURCE_DIR}/src
)

target_link_libraries(sandbox
    PRIVATE
        engine
        imgui
)

# Apply strict compiler warnings
moss_apply_compiler_warnings(sandbox)

# Platform-specific link libraries
if(MOSS_PLATFORM_WINDOWS)
    # Windows GUI subsystem
    set_target_properties(sandbox PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
    target_link_libraries(sandbox
        PRIVATE
            user32.lib
            gdi32.lib
            shell32.lib
    )
elseif(MOSS_PLATFORM_LINUX)
    target_link_libraries(sandbox
        PRIVATE
            ${X11_LIBRARIES}
            pthread
    )
endif()
