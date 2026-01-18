# Build Moss Engine on Windows using Clang

param(
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$BuildType = "Release",
    [string]$Target = ""
)

$BuildDir = "build-windows-clang"

if (-not (Test-Path $BuildDir)) {
    Write-Host "Build directory not found. Run generate_windows_clang.ps1 first." -ForegroundColor Red
    exit 1
}

Push-Location $BuildDir

try {
    $BuildArgs = @("--build", ".", "--config", $BuildType)
    
    if ($Target) {
        $BuildArgs += "--target", $Target
    }
    
    cmake @BuildArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Build completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
} finally {
    Pop-Location
}
