Updated README_ULTRALIGHT.md: removed uploaders and replaced UploadersLib with no-op stubs to strip upload functionality but keep compilation.

What changed:
- ShareX.UploadersLib project replaced with a minimal project containing UploaderStubs.cs. This preserves project references but removes all actual uploader implementations.
- Upload functionality now returns a failed UploadResult with a clear message so the app remains offline-only.

Why this approach:
- Fully deleting uploader projects can create many compilation errors across the codebase. Replacing UploadersLib with no-op stubs safely removes uploader behavior while ensuring the solution builds without heavy refactors.

If you want me to further remove uploader UI/menu entries or delete any remaining uploader-related resources, I can continue with those deletions in follow-up commits.
