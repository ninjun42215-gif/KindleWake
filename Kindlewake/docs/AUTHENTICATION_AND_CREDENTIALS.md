# Authentication, credentials and token-handling model

**Status: no player authentication is implemented or required by the current product.**

Kindlewake is an offline-first, single-player Godot game. The intended runtime has no player accounts, authentication server, multiplayer service, API backend or internet access. Do not add login screens, OAuth, JWTs, refresh tokens, password storage or remote session handling unless the product requirements deliberately change.

This document separates three concepts that are easy to confuse:

1. **Player authentication** — proving a player's identity to a game service. Kindlewake currently has no such service.
2. **Local game persistence** — saving campaign progress and settings on the device. This is not authentication.
3. **Android/GitHub release signing** — proving that an APK was signed by the expected developer identity. This is build/release integrity, not player identity.

## 1. Component map

| Component | Current responsibility | Authentication role |
|---|---|---|
| Godot game runtime | Runs the single-player campaign locally | None; no account/session provider |
| Title menu (New Game / Continue / Load Game / Settings) | Starts or resumes a local campaign | No sign-in step |
| `SaveSystem` | Stores campaign saves/autosaves in app-private device storage; save schema and migrations preserve game state | Saves are game data, not credentials or bearer tokens |
| `user://settings.cfg` | Stores local settings such as battle Auto Battle preference | No identity or secret-token role |
| `export_presets.cfg` | Defines Android packaging and permissions | Sets `permissions/internet=false`; does not configure an auth provider |
| `tools/build_apk.py` | Performs build preflight, imports/tests/exports and verifies the resulting APK | Rejects network-related runtime APIs and an APK that requests INTERNET |
| GitHub Actions release workflow | Builds candidate APKs and, in a separate protected lane, signs production releases | Uses repository/environment-scoped release credentials; these are never player credentials |

Relevant source and documentation:
- `Kindlewake/export_presets.cfg`: Android preset, `permissions/internet=false`, and export filters that exclude keystore files.
- `Kindlewake/tools/build_apk.py`: `NETWORK_CLASSES` preflight pattern, APK permission inspection, signature verification and build-key environment overrides.
- `Kindlewake/docs/ANDROID_RELEASE_WORKFLOW.md`: development vs production signing lanes and protected environment secrets.
- `Kindlewake/docs/BUILD_APK.md`: local saves and app installation/update behavior.
- `Kindlewake/README.md` and `Kindlewake/docs/GDD.md`: offline-first product requirements and local save/settings behavior.

## 2. Request and data flow

### Player runtime

There is no authentication request flow. The expected flow is:

```text
Launch game
   |
   v
Title menu
   |-- New Game ------> initialize a local campaign
   |-- Continue ------> read the newest valid local save/autosave
   |-- Load Game ------> read a selected local save
   |-- Settings -------> read/write local settings
   |
   v
Gameplay <----> local campaign state
   |
   +----------> SaveSystem writes local save/autosave
```

No username/password form is submitted. No authorization header, cookie-based login session, OAuth redirect, API key, access token or refresh-token exchange is part of this runtime. There is no remote identity endpoint to receive such a request.

The project documentation describes campaign saves and autosaves as local and states that saves live in the app's private storage. The Android export preset also sets `user_data_backup/allow=false`; do not confuse that Android backup setting with encryption or authentication.

### Build and release flow (separate from gameplay)

```text
Developer pushes reviewed source / starts a release workflow
   |
   v
GitHub Actions
   |-- CI lane: test/sideload signing identity
   |
   +-- Production lane: protected android-production environment
             |
             +--> reviewer/deployment protection
             +--> release keystore + alias/password from environment secrets
             +--> build APK and verify signer fingerprint
             +--> publish release assets only after checks
```

This is developer/release authorization. It does not create an account for a person playing the game and does not put a player token in the APK.

## 3. Credentials, keys and tokens

### Player credentials and session tokens

- No player passwords are collected or stored.
- No player access tokens, refresh tokens, API keys, session cookies or OAuth credentials are issued or persisted.
- No password hashing or token refresh/expiry logic is needed in the current offline architecture.
- Local save files may contain valuable gameplay progress and personal choices, but they are not proof of identity and must never be treated as authentication credentials.

### Android signing identity

Android signing keys establish continuity of the app publisher identity for installation and updates. They are not user login credentials.

- The repository documents a public/test sideload key for development builds. It must not be used for Google Play or production distribution.
- Production signing material belongs only in the protected GitHub Environment named `android-production`.
- The documented production secrets are `ANDROID_RELEASE_KEYSTORE_BASE64`, `ANDROID_RELEASE_KEY_ALIAS` and `ANDROID_RELEASE_KEY_PASSWORD`.
- `ANDROID_RELEASE_CERT_SHA256` is an expected certificate fingerprint stored as an environment variable, not a secret password. The release workflow compares the APK signer against it.
- The production workflow writes the decoded keystore to the ephemeral runner's temporary directory and removes it with the runner. Never commit or upload the private keystore or passwords.
- Keep a secure offline backup of the production signing identity. Losing it can prevent users from installing future updates signed with a different key.

The builder also exposes `KINDLEWAKE_KEYSTORE`, `KINDLEWAKE_KEY_ALIAS` and `KINDLEWAKE_KEY_PASS` as local build overrides. Treat these as sensitive environment inputs; do not put literal values in source, command history, logs or issue comments.

### GitHub workflow credentials

GitHub's own workflow/repository permissions authorize CI to read source and publish permitted artifacts. They are infrastructure credentials, not game tokens. Keep workflow permissions least-privileged, avoid persisting checkout credentials unnecessarily, and keep production publishing behind environment approval. Never copy a GitHub token into the Godot project or APK.

## 4. Security boundaries and what is (not) protected

- The Android preset explicitly disables INTERNET permission.
- The builder checks project scripts for a defined set of network-capable Godot APIs and checks the finished APK's requested permissions. A detected network API or INTERNET permission is a build-policy failure, not a signal to add an auth flow.
- The Android preset excludes keystore files and development/build/documentation directories from the APK export.
- The release guide says source handoffs exclude keystores, JKS, P12/PFX, PEM, private-key files, common secret files and generated build/cache directories.
- The release guide separates ordinary CI signing from protected production signing.

**Do not overstate these controls.** They do not prove that local save files are encrypted, tamper-proof or recoverable. Android app-private storage is an access boundary provided by the operating system; it is not a cryptographic guarantee against a rooted device, a compromised process or a user modifying their own local data. The preset's `encrypt_pck=false` concerns Godot resource-pack encryption and is not a save-file encryption setting.

## 5. Safe future changes

If the game remains fully offline:
1. Keep player authentication absent. Do not add fake login, local passwords or meaningless JWT-shaped data.
2. Preserve save schema compatibility and migrations. If save integrity becomes a concern, design a separate local integrity/versioning feature and document its limits; do not call it authentication.
3. Keep private signing credentials out of tracked source, APK assets, handoff archives, logs and chat.
4. Continue verifying the final APK's permissions and signer as part of release CI.

If online features are approved later (cloud saves, accounts, multiplayer or purchases), treat that as an architecture change requiring a threat model before implementation. Decide which service owns identity, use TLS, keep service secrets server-side, use short-lived access tokens and revocable refresh/session credentials where appropriate, validate authorization on the server for every protected operation, and design offline behavior and save conflict resolution explicitly. Never embed a privileged backend secret in a mobile APK. Update this document, the privacy policy and release permissions together with the feature.

## 6. Audit conclusion

As inspected against the current `main` documentation and Android export/build configuration, Kindlewake has **no player authentication subsystem**. The meaningful credential-handling surface is the developer/release pipeline's Android signing identity and GitHub Environment secrets. Local campaign saves/settings are persistence, not authentication. The correct current design is therefore to keep the game offline and protect release credentials—not to introduce a player login system.
