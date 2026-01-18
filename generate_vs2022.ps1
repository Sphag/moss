# Generate Visual Studio 2022 project files for Moss Engine

$BuildDir = "build-vs2022"

if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

Push-Location $BuildDir

try {
    cmake .. -G "Visual Studio 17 2022" -A x64
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Visual Studio 2022 project files generated successfully!" -ForegroundColor Green
        Write-Host "Open $BuildDir\MossEngine.sln in Visual Studio 2022" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Failed to generate Visual Studio 2022 project files" -ForegroundColor Red
        Write-Host "Make sure Visual Studio 2022 is installed" -ForegroundColor Red
    }
} finally {
    Pop-Location
}
