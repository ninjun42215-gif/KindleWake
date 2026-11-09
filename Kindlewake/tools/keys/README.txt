kindlewake-sideload.keystore
----------------------------
A throw-away signing key for SIDELOADED test builds (same idea as Android's public "debug" key).
  alias: kindlewake   store/key password: kindlewake-sideload
It is committed on purpose so every APK you build (on your PC or in GitHub Actions) is signed with the
SAME key. Android only lets a new APK update an installed one when both use the same key.
It is NOT secret, so do not use it for Google Play. For a store release make a private key:
    keytool -genkeypair -v -keystore release.keystore -alias mykey -keyalg RSA -keysize 2048 -validity 36500
and keep that file and its password safe (lose it = you can never update the published app).
