param(
    [string]$SolutionPath = "./ShareX.sln",
    [string]$Configuration = "Release",
    [string]$OutDir = "./dist/ShareX-UltraLight",
    [switch]$InstallToAppData
)

Write-Host "Building solution: $SolutionPath (Configuration: $Configuration)"

# Build
$msbuild = (Get-Command msbuild -ErrorAction SilentlyContinue)
if (-not $msbuild) {
    Write-Error "msbuild not found on PATH. Please install Build Tools / Visual Studio or run from Developer Command Prompt."
    exit 1
}

& msbuild $SolutionPath /p:Configuration=$Configuration /t:Rebuild
if ($LASTEXITCODE -ne 0) { Write-Error "Build failed"; exit $LASTEXITCODE }

# Collect output binaries from projects' bin/<Configuration> folders
Write-Host "Collecting build artifacts..."
if (Test-Path $OutDir) { Remove-Item -Recurse -Force $OutDir }
New-Item -ItemType Directory -Path $OutDir | Out-Null

$artifacts = Get-ChildItem -Path . -Recurse -Include *.exe,*.dll,*.config,*.pdb -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match "\\bin\\$Configuration\\" }

$copied = @{}
foreach ($f in $artifacts) {
    $target = Join-Path $OutDir $f.Name
    Copy-Item -Path $f.FullName -Destination $target -Force
    $copied[$f.FullName] = $target
}

Write-Host "Copied $(($copied.Keys).Count) artifact files to $OutDir"

# Copy ffmpeg if present
$ffmpegSrc = Join-Path -Path (Get-Location) -ChildPath "Tools\ffmpeg\ffmpeg.exe"
if (Test-Path $ffmpegSrc) {
    $ffmpegDestDir = Join-Path $OutDir "Tools\ffmpeg"
    New-Item -ItemType Directory -Path $ffmpegDestDir -Force | Out-Null
    Copy-Item -Path $ffmpegSrc -Destination $ffmpegDestDir -Force
    Write-Host "Copied ffmpeg to $ffmpegDestDir"
} else {
    Write-Warning "ffmpeg.exe not found at Tools\\ffmpeg\\ffmpeg.exe. Recorder will require ffmpeg to be placed in the packaged Tools\\ffmpeg folder or FFmpegPath updated in settings."
}

# Copy ultralight settings template into package
$settingsSrc = Join-Path (Get-Location) "Settings\ultralight_settings.json"
if (Test-Path $settingsSrc) {
    Copy-Item -Path $settingsSrc -Destination $OutDir -Force
    Write-Host "Copied ultralight settings to $OutDir"
} else {
    Write-Warning "Settings\\ultralight_settings.json not found in repo root."
}

# Optionally install settings to %APPDATA%\ShareX (for testing on the machine running script)
if ($InstallToAppData) {
    $appDataShareX = Join-Path -Path $env:APPDATA -ChildPath "ShareX"
    if (-not (Test-Path $appDataShareX)) { New-Item -ItemType Directory -Path $appDataShareX | Out-Null }
    Copy-Item -Path $settingsSrc -Destination (Join-Path $appDataShareX 'ultralight_settings.json') -Force
    Write-Host "Installed ultralight settings to $appDataShareX"
}

# Create a simple launcher script that ensures Settings file exists next to exe
$launcher = @"
@echo off
REM UltraLight ShareX launcher: ensures ultralight settings exist next to executable
SET ROOT=%~dp0
IF NOT EXIST "%APPDATA%\ShareX" (
    mkdir "%APPDATA%\ShareX"
)
IF NOT EXIST "%APPDATA%\ShareX\ultralight_settings.json" (
    copy "%~dp0ultralight_settings.json" "%APPDATA%\ShareX\ultralight_settings.json"
)
start "" "%~dp0ShareX.exe"
"@"
$launcherPath = Join-Path $OutDir "run-ultralight.bat"
Set-Content -Path $launcherPath -Value $launcher -Encoding ASCII
Write-Host "Wrote launcher: $launcherPath"

# Zip the distribution
$zipFile = "${OutDir}.zip"
if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory((Resolve-Path $OutDir).Path, $zipFile)
Write-Host "Packaged ultralight zip: $zipFile"

Write-Host "Done. Package is available at: $zipFile"
