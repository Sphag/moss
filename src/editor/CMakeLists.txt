# Editor executable - visual editor using the Engine
add_executable(editor
    main.cpp
)

target_include_directories(editor
    PRIVATE
        ${CMAKE_SOURCE_DIR}/src
)

target_link_libraries(editor
    PRIVATE
        engine
        imgui
)

# Apply strict compiler warnings
moss_apply_compiler_warnings(editor)

# Platform-specific link libraries
if(MOSS_PLATFORM_WINDOWS)
    # Windows GUI subsystem
    set_target_properties(editor PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
    target_link_libraries(editor
        PRIVATE
            user32.lib
            gdi32.lib
            shell32.lib
    )
elseif(MOSS_PLATFORM_LINUX)
    target_link_libraries(editor
        PRIVATE
            ${X11_LIBRARIES}
            pthread
    )
endif()

# Copy assets to output directory
add_custom_command(TARGET editor POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/assets
        $<TARGET_FILE_DIR:editor>/assets
    COMMENT "Copying assets to output directory"
)
