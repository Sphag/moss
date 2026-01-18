# Compiler Warnings Configuration
# Provides consistent warning flags across all C++ targets

# Option to treat warnings as errors (ON by default)
option(MOSS_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" ON)

# MSVC warning flags
set(MOSS_MSVC_WARNINGS
    /W4          # Warning level 4 (all reasonable warnings)
    /permissive- # Conformance mode
    /w14242      # 'identifier': conversion from 'type1' to 'type2', possible loss of data
    /w14254      # 'operator': conversion from 'type1:field_bits' to 'type2:field_bits', possible loss of data
    /w14263      # 'function': member function does not override any base class virtual member function
    /w14265      # 'classname': class has virtual functions, but destructor is not virtual
    /w14287      # 'operator': unsigned/negative constant mismatch
    /we4289      # nonstandard extension used: 'variable': loop control variable declared in the for-loop is used outside the for-loop scope
    /w14296      # 'operator': expression is always 'boolean_value'
    /w14311      # 'variable': pointer truncation from 'type' to 'type'
    /w14545      # expression before comma evaluates to a function which is missing an argument list
    /w14546      # function call before comma missing argument list
    /w14547      # 'operator': operator before comma has no effect; expected operator with side-effect
    /w14549      # 'operator': operator before comma has no effect; did you intend 'operator'?
    /w14555      # expression has no effect; expected expression with side-effect
    /w14619      # pragma warning: there is no warning number 'number'
    /w14640      # Enable warning on thread un-safe static member initialization
    /w14826      # Conversion from 'type1' to 'type2' is sign-extended. This may cause unexpected runtime behavior
    /w14905      # wide string literal cast to 'LPSTR'
    /w14906      # string literal cast to 'LPWSTR'
    /w14928      # illegal copy-initialization; more than one user-defined conversion has been implicitly applied
)

if(MOSS_WARNINGS_AS_ERRORS AND MSVC)
    list(APPEND MOSS_MSVC_WARNINGS /WX)
endif()

# GCC/Clang warning flags
set(MOSS_GCC_CLANG_WARNINGS
    -Wall        # Enable all reasonable warnings
    -Wextra      # Enable extra warnings
    -Wpedantic   # Strict ISO C++ warnings
    -Wconversion # Warn about implicit conversions that may alter a value
    -Wsign-conversion # Warn for implicit conversions that may change the sign of an integer value
    -Wcast-align # Warn when casting pointers to increase required alignment
    -Wcast-qual  # Warn when casting removes type qualifiers
    -Wold-style-cast # Warn about C-style casts
    -Wdouble-promotion # Warn when implicit conversion doubles a float
    -Wformat=2   # Warn about security issues in format functions
    -Wnull-dereference # Warn if a null dereference is detected
    -Winit-self  # Warn about uninitialized variables initialized to themselves
    -Wstrict-overflow=5 # Warn about optimizations that may break strict aliasing
    -Wundef      # Warn if an undefined identifier is evaluated
    -Wshadow     # Warn when a local variable shadows another variable
)

if(MOSS_WARNINGS_AS_ERRORS AND Clang)
    list(APPEND MOSS_GCC_CLANG_WARNINGS -Werror)
endif()

# Function to apply compiler warnings to a target
function(moss_apply_compiler_warnings target)
    target_compile_options(${target} PRIVATE
        $<$<CXX_COMPILER_ID:MSVC>:${MOSS_MSVC_WARNINGS}>
        $<$<CXX_COMPILER_ID:GNU,Clang>:${MOSS_GCC_CLANG_WARNINGS}>
    )
endfunction()

# Function to disable/suppress warnings for a target (for external libraries)
function(moss_suppress_compiler_warnings target)
    if(MSVC)
        # MSVC: disable all warnings
        target_compile_options(${target} PRIVATE
            /W0  # Disable all warnings
        )
    else()
        # GCC/Clang: disable all warnings
        target_compile_options(${target} PRIVATE
            -w   # Disable all warnings
        )
    endif()
endfunction()

# Function to suppress specific warnings for a target
function(moss_suppress_warnings target)
    cmake_parse_arguments(
        SUPPRESS
        ""
        ""
        "WARNINGS"
        ${ARGN}
    )
    
    if(MSVC)
        foreach(WARNING ${SUPPRESS_WARNINGS})
            # MSVC: /wd#### suppresses warning ####
            target_compile_options(${target} PRIVATE /wd${WARNING})
        endforeach()
    else()
        foreach(WARNING ${SUPPRESS_WARNINGS})
            # GCC/Clang: -Wno-#### suppresses warning ####
            target_compile_options(${target} PRIVATE -Wno-${WARNING})
        endforeach()
    endif()
endfunction()
