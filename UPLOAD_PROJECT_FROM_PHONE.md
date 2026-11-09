# One-time KindleWake project import from an Android phone

The extracted `Kindlewake/` folder becomes the source of truth after this one-time import. You do **not** need to upload a 71 MB master ZIP.

## Files to upload

Upload these four files to the repository root:

- `KindleWake_Project_part1.zip`
- `KindleWake_Project_part2.zip`
- `KindleWake_Project_part3.zip`
- `KindleWake_Project_part4.zip`

Each file is approximately 18 MB, below GitHub's 25 MB browser-upload limit. They are transport shards, not separate game archives. The large optional sprite source archive `zxf.zip` is split into three internal chunks and reconstructed automatically by the workflow.

## Phone steps

1. Open [the repository upload page](https://github.com/ninjun42215-gif/KindleWake/upload/main).
2. Choose all four part files from Downloads. If the mobile picker only allows one file at a time, add the four files in one upload session before committing.
3. Commit the upload to `main` with message `Upload KindleWake project parts`.
4. Open **Actions → Extract KindleWake Upload Parts → Run workflow** if the workflow did not start automatically.
5. Wait for the workflow to finish. It validates every path, rebuilds `Kindlewake/` transactionally, reconstructs `assets/optional_sprite_packs/zxf.zip`, runs the static GDScript checker and Android build preflight, and commits the extracted project. It removes the temporary part ZIPs and legacy master ZIP after successful extraction.
6. Confirm `Kindlewake/project.godot` and `Kindlewake/docs/CONTINUATION_PROMPT.md` are visible in the repository.

## After the initial import

Do not upload another master ZIP. Edit or upload changed files directly under `Kindlewake/` and commit them normally. The repository tree is the canonical source. Keep `Kindlewake/docs/SESSION_HANDOFF.md`, `Kindlewake/docs/GDD.md`, `Kindlewake/docs/CONTINUATION_PROMPT.md`, and `Kindlewake/README.md` current as development continues.

If the workflow fails, open its run page and share the failing step and log. Do not delete existing repository files or force-push to recover.
