# Shader Compilation Module
# Provides macros and functions for compiling HLSL shaders using DXC
# Supports both Vulkan (SPIR-V) and D3D12 (DXIL) outputs


# Find DXC executable
set(DXC_EXE ${DXC_EXE_PATH}/dxc)

if(DXC_EXE)
    message(STATUS "DXC found: ${DXC_EXE}")
else()
    message(WARNING "DXC not found. Shader compilation will not work.")
    message(WARNING "Please build DXC and place it in ${DXC_EXE_PATH}")
endif()

# Function to compile HLSL shader to SPIR-V for Vulkan
# Usage: compile_hlsl_to_spirv(INPUT "shader.hlsl" OUTPUT "shader.spv" ENTRY "main" PROFILE "vs_6_0")
function(compile_hlsl_to_spirv)
    cmake_parse_arguments(
        HLSL_SPIRV
        ""
        "INPUT;OUTPUT;ENTRY;PROFILE"
        ""
        ${ARGN}
    )
    
    if(NOT HLSL_SPIRV_INPUT OR NOT HLSL_SPIRV_OUTPUT)
        message(FATAL_ERROR "compile_hlsl_to_spirv requires INPUT and OUTPUT parameters")
    endif()
    
    if(NOT DXC_EXE)
        message(WARNING "DXC not found. Cannot compile ${HLSL_SPIRV_INPUT} to SPIR-V")
        return()
    endif()
    
    get_filename_component(INPUT_ABS ${HLSL_SPIRV_INPUT} ABSOLUTE)
    get_filename_component(OUTPUT_ABS ${HLSL_SPIRV_OUTPUT} ABSOLUTE)
    
    # Default values
    if(NOT HLSL_SPIRV_ENTRY)
        set(HLSL_SPIRV_ENTRY "main")
    endif()
    
    if(NOT HLSL_SPIRV_PROFILE)
        set(HLSL_SPIRV_PROFILE "vs_6_0")
    endif()
    
    # Create output directory
    get_filename_component(OUTPUT_DIR ${OUTPUT_ABS} DIRECTORY)
    file(MAKE_DIRECTORY ${OUTPUT_DIR})
    
    # Compile HLSL to SPIR-V for Vulkan
    # DXC options:
    # -spirv: Generate SPIR-V
    # -T <profile>: Shader target profile (e.g., vs_6_0, ps_6_0, cs_6_0)
    # -E <entry>: Entry point name
    # -Fo <file>: Output file
    add_custom_command(
        OUTPUT ${OUTPUT_ABS}
        COMMAND ${DXC_EXE}
            -spirv
            -T ${HLSL_SPIRV_PROFILE}
            -E ${HLSL_SPIRV_ENTRY}
            -Fo "${OUTPUT_ABS}"
            "${INPUT_ABS}"
        DEPENDS ${INPUT_ABS}
        COMMENT "Compiling HLSL to SPIR-V: ${HLSL_SPIRV_INPUT}"
    )
    
    # Add output to global property
    get_property(SHADER_TARGETS GLOBAL PROPERTY MOSS_SHADER_TARGETS)
    if(NOT SHADER_TARGETS)
        define_property(GLOBAL PROPERTY MOSS_SHADER_TARGETS BRIEF_DOCS "Shader compilation targets" FULL_DOCS "List of shader output files")
    endif()
    set_property(GLOBAL APPEND PROPERTY MOSS_SHADER_TARGETS ${OUTPUT_ABS})
endfunction()

# Function to compile HLSL shader to DXIL for D3D12
# Usage: compile_hlsl_to_dxil(INPUT "shader.hlsl" OUTPUT "shader.dxil" ENTRY "main" PROFILE "vs_6_0")
function(compile_hlsl_to_dxil)
    cmake_parse_arguments(
        HLSL_DXIL
        ""
        "INPUT;OUTPUT;ENTRY;PROFILE"
        ""
        ${ARGN}
    )
    
    if(NOT HLSL_DXIL_INPUT OR NOT HLSL_DXIL_OUTPUT)
        message(FATAL_ERROR "compile_hlsl_to_dxil requires INPUT and OUTPUT parameters")
    endif()
    
    if(NOT MOSS_PLATFORM_WINDOWS)
        message(WARNING "DXIL compilation is only supported on Windows")
        return()
    endif()
    
    if(NOT DXC_EXE)
        message(WARNING "DXC not found. Cannot compile ${HLSL_DXIL_INPUT} to DXIL")
        return()
    endif()
    
    get_filename_component(INPUT_ABS ${HLSL_DXIL_INPUT} ABSOLUTE)
    get_filename_component(OUTPUT_ABS ${HLSL_DXIL_OUTPUT} ABSOLUTE)
    
    # Default values
    if(NOT HLSL_DXIL_ENTRY)
        set(HLSL_DXIL_ENTRY "main")
    endif()
    
    if(NOT HLSL_DXIL_PROFILE)
        set(HLSL_DXIL_PROFILE "vs_6_0")
    endif()
    
    # Create output directory
    get_filename_component(OUTPUT_DIR ${OUTPUT_ABS} DIRECTORY)
    file(MAKE_DIRECTORY ${OUTPUT_DIR})
    
    # Compile HLSL to DXIL for D3D12
    # DXC options:
    # -T <profile>: Shader target profile (e.g., vs_6_0, ps_6_0, cs_6_0)
    # -E <entry>: Entry point name
    # -Fo <file>: Output file (will be DXIL by default, unless -spirv is used)
    add_custom_command(
        OUTPUT ${OUTPUT_ABS}
        COMMAND ${DXC_EXE}
            -T ${HLSL_DXIL_PROFILE}
            -E ${HLSL_DXIL_ENTRY}
            -Fo "${OUTPUT_ABS}"
            "${INPUT_ABS}"
        DEPENDS ${INPUT_ABS}
        COMMENT "Compiling HLSL to DXIL: ${HLSL_DXIL_INPUT}"
    )
    
    # Add output to global property
    get_property(SHADER_TARGETS GLOBAL PROPERTY MOSS_SHADER_TARGETS)
    if(NOT SHADER_TARGETS)
        define_property(GLOBAL PROPERTY MOSS_SHADER_TARGETS BRIEF_DOCS "Shader compilation targets" FULL_DOCS "List of shader output files")
    endif()
    set_property(GLOBAL APPEND PROPERTY MOSS_SHADER_TARGETS ${OUTPUT_ABS})
endfunction()

# Helper function to compile HLSL shader for both Vulkan and D3D12
# Usage: compile_hlsl_shader(INPUT "shader.hlsl" ENTRY "main" PROFILE "vs_6_0" OUTPUT_DIR "build/shaders")
function(compile_hlsl_shader)
    cmake_parse_arguments(
        HLSL
        ""
        "INPUT;ENTRY;PROFILE;OUTPUT_DIR"
        ""
        ${ARGN}
    )
    
    if(NOT HLSL_INPUT OR NOT HLSL_OUTPUT_DIR)
        message(FATAL_ERROR "compile_hlsl_shader requires INPUT and OUTPUT_DIR parameters")
    endif()
    
    get_filename_component(INPUT_ABS ${HLSL_INPUT} ABSOLUTE)
    get_filename_component(NAME_WE ${INPUT_ABS} NAME_WE)
    
    # Default values
    if(NOT HLSL_ENTRY)
        set(HLSL_ENTRY "main")
    endif()
    
    if(NOT HLSL_PROFILE)
        set(HLSL_PROFILE "vs_6_0")
    endif()
    
    # Compile to SPIR-V for Vulkan
    compile_hlsl_to_spirv(
        INPUT ${INPUT_ABS}
        OUTPUT "${HLSL_OUTPUT_DIR}/${NAME_WE}.spv"
        ENTRY ${HLSL_ENTRY}
        PROFILE ${HLSL_PROFILE}
    )
    
    # Compile to DXIL for D3D12 (Windows only)
    if(MOSS_PLATFORM_WINDOWS)
        compile_hlsl_to_dxil(
            INPUT ${INPUT_ABS}
            OUTPUT "${HLSL_OUTPUT_DIR}/${NAME_WE}.dxil"
            ENTRY ${HLSL_ENTRY}
            PROFILE ${HLSL_PROFILE}
        )
    endif()
endfunction()

# Helper function to compile all HLSL shaders in a directory
# Usage: compile_hlsl_shaders_in_directory(DIRECTORY "assets/shaders" OUTPUT_DIR "build/shaders")
function(compile_hlsl_shaders_in_directory)
    cmake_parse_arguments(
        SHADER_DIR
        ""
        "DIRECTORY;OUTPUT_DIR"
        ""
        ${ARGN}
    )
    
    if(NOT SHADER_DIR_DIRECTORY OR NOT SHADER_DIR_OUTPUT_DIR)
        message(FATAL_ERROR "compile_hlsl_shaders_in_directory requires DIRECTORY and OUTPUT_DIR parameters")
    endif()
    
    # Find all HLSL files
    file(GLOB_RECURSE HLSL_FILES "${SHADER_DIR_DIRECTORY}/*.hlsl")
    
    foreach(HLSL ${HLSL_FILES})
        get_filename_component(NAME ${HLSL} NAME)
        
        # Try to infer profile from filename or directory
        # Common patterns: *_vs.hlsl, *_ps.hlsl, *_cs.hlsl, etc.
        string(TOUPPER ${NAME} NAME_UPPER)
        if(NAME_UPPER MATCHES "_VS")
            set(PROFILE "vs_6_0")
        elseif(NAME_UPPER MATCHES "_PS")
            set(PROFILE "ps_6_0")
        elseif(NAME_UPPER MATCHES "_CS")
            set(PROFILE "cs_6_0")
        elseif(NAME_UPPER MATCHES "_GS")
            set(PROFILE "gs_6_0")
        elseif(NAME_UPPER MATCHES "_HS")
            set(PROFILE "hs_6_0")
        elseif(NAME_UPPER MATCHES "_DS")
            set(PROFILE "ds_6_0")
        else()
            set(PROFILE "vs_6_0")  # Default to vertex shader
        endif()
        
        compile_hlsl_shader(
            INPUT ${HLSL}
            OUTPUT_DIR ${SHADER_DIR_OUTPUT_DIR}
            PROFILE ${PROFILE}
        )
    endforeach()
endfunction()

message(STATUS "Shader compilation module loaded (using DXC)")
