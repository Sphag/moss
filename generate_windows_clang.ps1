# Generate build files for Windows using Clang

param(
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$BuildType = "Release"
)

$BuildDir = "build-windows-clang"

if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

Push-Location $BuildDir

try {
    cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=$BuildType -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Windows Clang build files generated successfully!" -ForegroundColor Green
        Write-Host "Build type: $BuildType" -ForegroundColor Green
        Write-Host ""
        Write-Host "To build, run: cmake --build ." -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Failed to generate build files" -ForegroundColor Red
        Write-Host "Make sure Clang and Ninja are installed and in PATH" -ForegroundColor Red
        Write-Host ""
        Write-Host "Install Clang: https://clang.llvm.org/" -ForegroundColor Yellow
        Write-Host "Install Ninja: https://ninja-build.org/" -ForegroundColor Yellow
    }
} finally {
    Pop-Location
}
