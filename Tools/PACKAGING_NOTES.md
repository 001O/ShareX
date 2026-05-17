## Packaging script

Use Tools\package_ultralight.ps1 to build the ShareX solution and create a portable ultralight zip.

Examples

PowerShell (recommended):

    # Build and package into ./dist/ShareX-UltraLight.zip
    .\Tools\package_ultralight.ps1

    # Build, package and install ultralight settings to %%APPDATA%%\ShareX for quick testing
    .\Tools\package_ultralight.ps1 -InstallToAppData

Command Prompt (convenience):

    Tools\package_ultralight.bat

Notes
- The script looks for msbuild on PATH. Run from a Developer Command Prompt or ensure msbuild is available.
- Place a compatible ffmpeg.exe at Tools\ffmpeg\ffmpeg.exe so the packaged build includes it.
- The script uses a simple heuristic to copy binaries from project bin\<Configuration> folders - please verify the produced zip contains the main ShareX.exe and required DLLs.
