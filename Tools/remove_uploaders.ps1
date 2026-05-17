<powershell>
<#
Tools/remove_uploaders.ps1

Usage:
  # Dry-run first to see what would be removed
  .\Tools\remove_uploaders.ps1 -DryRun

  # Remove with backup (default)
  .\Tools\remove_uploaders.ps1

  # Remove without backup (destructive)
  .\Tools\remove_uploaders.ps1 -NoBackup

Notes:
- This script searches the repository for common uploader/cloud integration folders, project files, and files that mention known uploaders and deletes them (or moves them to a backup folder).
- It will also attempt to remove matching project entries from the .sln file(s) in the repository root.
- After running, you should open the solution in Visual Studio and attempt a build. There may be compilation errors where uploaders were referenced; please report them and I can provide fixes/stubs.
- Use -DryRun to verify the removal list before deleting anything.
- By default a timestamped backup folder will be created named .removed_uploaders_backup_<timestamp>. Use -NoBackup to skip creating backups (destructive).
#>

param(
    [switch]$DryRun,
    [switch]$NoBackup
)

$patterns = @(
    'Imgur','Dropbox','GoogleDrive','Google Drive','OneDrive','FTP','SFTP','WebDAV','Box','Twitter','Tumblr','ImgBB','SM.MS','SMMS','ImageShack','GooglePhotos','Cloud','Uploaders','UploadServices','Uploader','Upload'
)

Write-Host "Scanning repository for uploader/cloud integration artifacts..."

$cwd = Get-Location

# Find candidate directories whose name matches patterns
$dirCandidates = Get-ChildItem -Path $cwd -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object {
    foreach ($p in $patterns) { if ($_.Name -match [regex]::Escape($p)) { return $true } }
    $false
}

# Find csproj files that include known keywords or live in matched directories
$csprojFiles = Get-ChildItem -Path $cwd -Recurse -Include *.csproj -ErrorAction SilentlyContinue | Where-Object {
    $content = Get-Content -Raw -ErrorAction SilentlyContinue -Path $_.FullName
    foreach ($p in $patterns) { if ($content -match [regex]::Escape($p)) { return $true } }
    foreach ($d in $dirCandidates) { if ($_.FullName -like "$($d.FullName)/*" -or $_.FullName -like "$($d.FullName)\\*") { return $true } }
    $false
}

# Find files that reference common uploader interface/class names
$fileRefs = Get-ChildItem -Path $cwd -Recurse -Include *.cs,*.xaml,*.config,*.xml,*.json -ErrorAction SilentlyContinue | Where-Object {
    $content = Get-Content -Raw -ErrorAction SilentlyContinue -Path $_.FullName
    foreach ($p in @('IUploader','Uploader','UploadService','UploadResult','Upload') ) { if ($content -match $p) { return $true } }
    $false
}

# Consolidate list for display
$toRemovePaths = @()
$toRemovePaths += $dirCandidates | ForEach-Object { $_.FullName }
$toRemovePaths += $csprojFiles | ForEach-Object { $_.FullName }
$toRemovePaths = $toRemovePaths | Sort-Object -Unique

Write-Host "Found $($dirCandidates.Count) directories, $($csprojFiles.Count) project files referencing known uploaders."
Write-Host "Potential files/directories to remove or process (summary):"
$toRemovePaths | ForEach-Object { Write-Host " - $_" }

if ($DryRun) {
    Write-Host "Dry-run requested; exiting without deleting any files." -ForegroundColor Yellow
    exit 0
}

# Prepare backup folder
$timestamp = (Get-Date).ToString('yyyyMMddHHmmss')
$backupFolder = Join-Path $cwd ".removed_uploaders_backup_$timestamp"
if (-not $NoBackup) {
    New-Item -ItemType Directory -Path $backupFolder | Out-Null
    Write-Host "Backup folder: $backupFolder"
}

# Move directories to backup or delete
foreach ($d in $dirCandidates) {
    $full = $d.FullName
    if (-not $NoBackup) {
        $dest = Join-Path $backupFolder ($d.FullName.TrimStart((Get-Location).Path.TrimEnd('\') + '\'))
        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Write-Host "Moving directory to backup: $full -> $dest"
        Move-Item -Path $full -Destination $dest -Force
    } else {
        Write-Host "Removing directory: $full"
        Remove-Item -Path $full -Recurse -Force
    }
}

# Move or remove csproj files (if parent directory already moved, they moved too)
foreach ($proj in $csprojFiles) {
    if (Test-Path $proj.FullName) {
        if (-not $NoBackup) {
            $dest = Join-Path $backupFolder ($proj.FullName.TrimStart((Get-Location).Path.TrimEnd('\') + '\'))
            $destDir = Split-Path $dest -Parent
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            Write-Host "Moving project file to backup: $($proj.FullName) -> $dest"
            Move-Item -Path $proj.FullName -Destination $dest -Force
        } else {
            Write-Host "Removing project file: $($proj.FullName)"
            Remove-Item -Path $proj.FullName -Force
        }
    }
}

# Update .sln files: remove Project lines referencing removed project filenames
$slnFiles = Get-ChildItem -Path $cwd -Filter *.sln -ErrorAction SilentlyContinue
foreach ($sln in $slnFiles) {
    $slnPath = $sln.FullName
    Write-Host "Processing solution file: $slnPath"
    $slnText = Get-Content -Raw -Path $slnPath -ErrorAction SilentlyContinue

    foreach ($proj in $csprojFiles) {
        $projName = Split-Path $proj.FullName -Leaf
        # Remove Project(...) lines that reference the .csproj
        $pattern = "(?ms)^Project\([^\)]+\)\s*=.*$projName.*?EndProject\r?\n"
        if ($slnText -match [regex]$pattern) {
            Write-Host " - Removing project entry for $projName from $($slnPath)"
            $slnText = [regex]::Replace($slnText, $pattern, "")
        }
    }

    # Save updated solution
    if (-not $NoBackup) {
        $slnBackup = "$slnPath.rmvbak_$timestamp"
        Copy-Item -Path $slnPath -Destination $slnBackup -Force
        Write-Host " - Created backup of solution: $slnBackup"
    }
    Set-Content -Path $slnPath -Value $slnText -Force
}

Write-Host "Removal complete. If you used the default behavior, removed items are in: $backupFolder" -ForegroundColor Green
Write-Host "Next steps: open the solution in Visual Studio, build Release, and report any compile/runtime errors to me so I can provide stubs/fixes." -ForegroundColor Cyan
</powershell>
