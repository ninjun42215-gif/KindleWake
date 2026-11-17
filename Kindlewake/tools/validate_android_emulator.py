#!/usr/bin/env python3
"""Install, launch and diagnose the KindleWake APK in the CI Android emulator."""
from __future__ import annotations

import os
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DIST = ROOT / "Kindlewake" / "dist"
APK = DIST / "Kindlewake.apk"
SERIAL = os.environ.get("ANDROID_SERIAL", "emulator-5554")
ENV = dict(os.environ, ANDROID_SERIAL=SERIAL)


def adb(*args: str, timeout: int = 30, check: bool = True) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        ["adb", *args],
        env=ENV,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
        check=False,
    )
    if check and result.returncode != 0:
        raise RuntimeError("adb " + " ".join(args) + " failed (" + str(result.returncode) + "):\n" + result.stdout)
    return result


def write_text(name: str, value: str) -> None:
    (DIST / name).write_text(value, encoding="utf-8")


def capture_diagnostics() -> str:
    chunks: list[str] = []
    for name, args in [
        ("android-devices.txt", ("devices", "-l")),
        ("android-activities.txt", ("shell", "dumpsys", "activity", "activities")),
        ("android-window-displays.txt", ("shell", "dumpsys", "window", "displays")),
        ("android-logcat.txt", ("logcat", "-d", "-v", "time")),
    ]:
        try:
            result = adb(*args, timeout=45, check=False)
            write_text(name, result.stdout)
            chunks.append("===== " + name + " =====\n" + result.stdout[-16000:])
        except Exception as exc:  # diagnostics must not mask the original failure
            chunks.append("===== " + name + " capture failed =====\n" + str(exc))
    return "\n".join(chunks)


def main() -> int:
    DIST.mkdir(parents=True, exist_ok=True)
    if not APK.is_file() or APK.stat().st_size == 0:
        print("ERROR: APK is missing or empty: " + str(APK), file=sys.stderr)
        return 1

    print("Waiting for Android emulator " + SERIAL)
    ready = False
    for attempt in range(1, 31):
        try:
            state = adb("get-state", timeout=8, check=False)
            if state.returncode == 0 and state.stdout.strip() == "device":
                boot = adb("shell", "getprop", "sys.boot_completed", timeout=8, check=False)
                if boot.returncode == 0 and boot.stdout.strip() == "1":
                    ready = True
                    break
        except Exception:
            pass
        time.sleep(2)
    if not ready:
        print("ERROR: emulator did not become ready. Capturing diagnostics.")
        print(capture_diagnostics())
        return 1

    try:
        for args in [
            ("shell", "wm", "size", "1368x632"),
            ("shell", "wm", "density", "230"),
            ("shell", "settings", "put", "system", "accelerometer_rotation", "0"),
            ("shell", "settings", "put", "system", "user_rotation", "1"),
            ("shell", "settings", "put", "system", "font_scale", "1.0"),
        ]:
            print("adb " + " ".join(args))
            adb(*args, timeout=20)

        print("Installing " + str(APK))
        adb("install", "-r", str(APK), timeout=180)
        adb("logcat", "-c", timeout=20)
        print("Launching the Godot activity without injecting random Monkey input")
        # Monkey with an event count of 1 can randomly tap a title-menu button
        # (including Exit Game). Use ActivityManager so this is a deterministic launch.
        adb("shell", "am", "start", "-W", "-n",
            "com.kindlewake.game/com.godot.game.GodotApp", timeout=45)
        time.sleep(30)

        # Capture logs before the process assertion so a startup crash is diagnosable.
        diagnostics = capture_diagnostics()
        logcat_path = DIST / "android-logcat.txt"
        logcat = logcat_path.read_text(encoding="utf-8", errors="replace") if logcat_path.exists() else ""
        pid = adb("shell", "pidof", "com.kindlewake.game", timeout=20, check=False)
        if pid.returncode != 0 or not pid.stdout.strip():
            print("ERROR: KindleWake process is not running 30 seconds after launch.")
            print(diagnostics[-24000:])
            return 1
        print("KindleWake process is alive: " + pid.stdout.strip())

        shot = "/sdcard/kindlewake-honor400-layout.png"
        adb("shell", "screencap", "-p", shot, timeout=30)
        local_shot = DIST / "honor400-emulator.png"
        adb("pull", shot, str(local_shot), timeout=60)
        if not local_shot.is_file() or local_shot.stat().st_size < 1024:
            raise RuntimeError("Emulator screenshot was not captured or is unexpectedly small.")

        error_pattern = re.compile(r"FATAL EXCEPTION|Fatal signal|SCRIPT ERROR|Parse Error", re.I)
        errors = [line for line in logcat.splitlines() if error_pattern.search(line)]
        if errors:
            print("ERROR: Android runtime or Godot script errors detected:")
            print("\n".join(errors[-80:]))
            return 1

        print("PASS: APK installed, launched, remained alive for 30 seconds, screenshot captured, and log scan clean.")
        return 0
    except Exception as exc:
        print("ERROR: Android emulator validation failed: " + str(exc), file=sys.stderr)
        print(capture_diagnostics())
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
