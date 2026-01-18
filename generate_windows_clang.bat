@echo off
REM Generate build files for Windows using Clang

set BUILD_DIR=build-windows-clang
set BUILD_TYPE=Release

if "%1"=="Debug" set BUILD_TYPE=Debug
if "%1"=="Release" set BUILD_TYPE=Release
if "%1"=="RelWithDebInfo" set BUILD_TYPE=RelWithDebInfo

if not exist %BUILD_DIR% mkdir %BUILD_DIR%

cd %BUILD_DIR%

cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Windows Clang build files generated successfully!
    echo Build type: %BUILD_TYPE%
    echo.
    echo To build, run: cmake --build .
    echo ========================================
) else (
    echo.
    echo Failed to generate build files
    echo Make sure Clang and Ninja are installed and in PATH
    echo.
    echo Install Clang: https://clang.llvm.org/
    echo Install Ninja: https://ninja-build.org/
)

cd ..
