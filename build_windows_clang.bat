@echo off
REM Build Moss Engine on Windows using Clang

set BUILD_DIR=build-windows-clang
set BUILD_TYPE=Release
set TARGET=

if "%1"=="Debug" set BUILD_TYPE=Debug
if "%1"=="Release" set BUILD_TYPE=Release
if "%1"=="RelWithDebInfo" set BUILD_TYPE=RelWithDebInfo
if not "%2"=="" set TARGET=--target %2

if not exist %BUILD_DIR% (
    echo Build directory not found. Run generate_windows_clang.bat first.
    exit /b 1
)

cd %BUILD_DIR%

cmake --build . --config %BUILD_TYPE% %TARGET%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build completed successfully!
    echo ========================================
) else (
    echo.
    echo Build failed!
    exit /b 1
)

cd ..
