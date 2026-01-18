@echo off
REM Generate Visual Studio 2026 project files for Moss Engine

set BUILD_DIR=build-vs2026

if not exist %BUILD_DIR% mkdir %BUILD_DIR%

cd %BUILD_DIR%

cmake .. -G "Visual Studio 18 2026" -A x64

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Visual Studio 2026 project files generated successfully!
    echo Open %BUILD_DIR%\MossEngine.sln in Visual Studio 2026
    echo ========================================
) else (
    echo.
    echo Failed to generate Visual Studio 2026 project files
    echo Make sure Visual Studio 2026 is installed
)

cd ..
