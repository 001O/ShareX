## README_ULTRALIGHT.md (appendix)

### Removing remaining uploaders and cloud integrations (automation)

If you want to fully strip uploaders and cloud integrations from your fork, there's a helper script included: `Tools/remove_uploaders.ps1`.

Usage (recommended):

1. Dry-run to see what will be removed:
   - PowerShell: `.\Tools\remove_uploaders.ps1 -DryRun`

2. If the list looks good, run to remove with backup (recommended):
   - PowerShell: `.\Tools\remove_uploaders.ps1`

3. If you do not want a backup (destructive), run:
   - PowerShell: `.\Tools\remove_uploaders.ps1 -NoBackup`

Notes:
- The script will attempt to remove common uploader project folders and referenced projects from the solution file(s). It is conservative but may still require manual fixes.
- After running, open the solution in Visual Studio and build. If there are compile errors due to references to uploader types, share the errors and I will prepare minimal stub implementations to restore compilability while keeping functionality local-only.


---
