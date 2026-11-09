# Receiving folder — contributions from other AI tools

This folder is the required intake point for any code, assets, patches or documents produced by another AI assistant. It is included in the automated source handoff ZIP.

## Where to put incoming work
Create a unique subfolder for each contribution, for example:

`Kindlewake/receiving/2026-11-10-ai-name-rune-vfx/`

Keep the original contribution intact. Do not overwrite canonical project files directly from an incoming bundle.

## Required files
Every contribution must include a `HANDOFF.md` containing:
- Contributor/AI and date
- Summary and exact intended target paths
- Complete file inventory
- Godot/runtime version and assumptions
- Dependencies/plugins
- Asset source, license, attribution and redistribution/modification rights
- Tests performed and exact results
- Known limitations/risks
- Manual import/integration steps
- Status: awaiting review

Use the template in the root `CONTINUATION_PROMPT.md`.

## If the AI output is a ZIP larger than 25 MB
Split the ZIP into consecutive binary chunks, each no larger than **25,000,000 bytes (25 MB decimal)**:
- `contribution.zip.part001`
- `contribution.zip.part002`
- `contribution.zip.part003`, etc.
- Include `REASSEMBLE.txt` with exact reassembly commands.

Linux/macOS example:
```sh
cat contribution.zip.part* > contribution.zip
unzip -t contribution.zip
unzip contribution.zip
```

Windows PowerShell example:
```powershell
$parts = Get-ChildItem 'contribution.zip.part*' | Sort-Object Name
$out = [System.IO.File]::Create('contribution.zip')
try { foreach ($part in $parts) { $input = [System.IO.File]::OpenRead($part.FullName); try { $input.CopyTo($out) } finally { $input.Dispose() } } } finally { $out.Dispose() }
7z t contribution.zip
```

## Required GitHub delivery and review flow
1. Commit the original ZIP/patch or every split part, `HANDOFF.md` and `REASSEMBLE.txt` to the unique receiving subfolder on the current authorized working branch (inspect live refs; do not assume a fixed branch name).
2. Push the branch. Never leave the only copy in chat or a temporary workspace.
3. Reassemble in the receiving folder, verify ZIP integrity, and extract to a separate review subfolder.
4. Review licensing, security, file paths, dependencies, Godot compatibility, UIDs, references, save schema and tests. Treat all incoming content as untrusted until reviewed.
5. Integrate approved files into canonical project paths; add tests and update the GDD, session handoff, README and continuation prompts.
6. Run the repository-wide validation workflow. It triggers on pushes to every branch, tags, pull requests targeting any branch and manual dispatch. The `Kindlewake-Source-Handoff-Parts` artifact is generated from the exact triggering Git ref and includes all tracked repository files, including the receiving folder and canonical changes.
7. Mark the intake HANDOFF.md accepted, rejected or deferred and record the integration commit. Keep original incoming files for provenance unless the user asks otherwise.

## Safety and compatibility
- Never include passwords, credentials, tokens, signing keys, personal data or generated build/cache directories.
- Do not let unreviewed incoming files be loaded by the game at runtime.
- Preserve Godot resource UIDs, scene references, sprite/frame contracts and save schema v3 unless dependent code and migrations are deliberately updated and tested.
- Check license terms before redistributing or modifying third-party assets. Record approved attribution in `assets/art/CREDITS.md`.
