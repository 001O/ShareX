# ShareX — UltraLight (local-only) build

This branch produces an ultra-light, local-only ShareX build intended for offline use. It keeps screenshot + recorder + basic editor functionality while disabling/removing cloud/upload/telemetry components.

## What’s included
- Screenshot capture (full / region / window)
- Minimal image editor (crop, annotate, blur)
- Screen recorder (uses local ffmpeg)
- Local-only defaults (save to disk; no uploads; no telemetry; no auto-update)

## What’s disabled
- Uploaders (Imgur, Dropbox, Google Drive, OneDrive, etc.) are disabled by default in the provided settings template.
- Auto-update checks and telemetry/analytics are turned off in the provided settings template.
- Cloud settings sync is disabled in the provided settings template.
- Sharing and social integration UIs will still exist in upstream code; this branch provides a non-destructive, configuration-first approach (template + docs). If you want full removal of uploader projects to reduce binary size, I can do that in a follow-up commit.

## How to use the ultralight settings
1. Copy `Settings/ultralight_settings.json` to ShareX's settings folder (or import it via the app if it supports profiles).
2. Place an `ffmpeg.exe` binary at `Tools/ffmpeg/ffmpeg.exe` relative to the repository root (or update `FFmpegPath` in the settings file).
3. Launch ShareX from the built output. The provided settings template ensures captures and recordings are saved locally by default.

## How to build locally
1. Ensure you have Visual Studio (matching repo target framework) or msbuild installed.
2. Place a local `ffmpeg.exe` in `Tools/ffmpeg/ffmpeg.exe` (or update `FFmpegPath` in the settings template).
3. From the repo root:
   - `msbuild ShareX.sln /p:Configuration=Release`
   - Or open `ShareX.sln` in Visual Studio and build Release.
4. Package the portable zip:
   - Copy `bin\\Release\\*` into a folder, include `Tools\\ffmpeg\\ffmpeg.exe` and `Settings\\ultralight_settings.json`
   - Zip the folder and run locally.

## Next steps I can take (tell me if you want me to proceed automatically):
- Update the app's default profile loader so the UltraLightLocal profile is available and auto-selected on first run (non-destructive change).
- Add feature flags to hide uploader menu entries in the UI (minimal UI stubs; low-risk).
- Remove uploader projects and references entirely to shrink the binary (higher risk; requires more refactors/testing).
- Build a portable release zip and attach it to the branch as a release artifact.

---

Committed to branch `ultra-light-local`.
