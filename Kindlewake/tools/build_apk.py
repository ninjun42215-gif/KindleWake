#!/usr/bin/env python3
"""Kindlewake: one-command Android APK builder (Windows and Linux, Python 3.8+, no extra packages).

What it does, in order:
  1. Preflight checks (offline): export preset, project settings, icons, signing key, JSON data, no network code.
  2. Downloads and caches (once, about 1.3 GB): JDK 17, Android SDK (platform-tools, build-tools, platform),
     the Godot editor and its export templates. Nothing is installed system-wide.
  3. Imports the project, runs the headless tests (their output is saved, they do not block the APK),
     exports a signed RELEASE APK to dist/Kindlewake.apk.
  4. Verifies the APK: valid zip, signature, and that it requests NO INTERNET permission.

Usage (from the project folder):
  python tools/build_apk.py                build the APK (dist/Kindlewake.apk) + run tests
  python tools/build_apk.py --check        offline preflight only (needs no downloads, no Godot)
  python tools/build_apk.py --skip-tests   build only
  python tools/build_apk.py --strict       fail the build if the tests report FAIL / SCRIPT ERROR
  python tools/build_apk.py --with-balance also run tests/balance_report.gd
  python tools/build_apk.py --install      afterwards `adb install -r` to a USB-connected phone
  python tools/build_apk.py --godot 4.2.2  Godot version to use (default below)
  python tools/build_apk.py --cache DIR    where to keep the downloads (default ~/.kindlewake_build)

Environment overrides: KINDLEWAKE_CACHE, KINDLEWAKE_JAVA_HOME, KINDLEWAKE_KEYSTORE,
KINDLEWAKE_KEY_ALIAS, KINDLEWAKE_KEY_PASS (use these for a private store-release key).
Logs go to dist/logs/; dist/logs/BUILD_SUMMARY.txt is the short report to paste into the chat.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import tarfile
import threading
import time
import urllib.error
import urllib.request
import zipfile
from pathlib import Path
from typing import Dict, List, Optional, Tuple

PROJECT = Path(__file__).resolve().parent.parent

GODOT_VERSION = "4.2.2"           # the version this project and script are written for
JDK_FEATURE = "17"
CMDLINE_TOOLS_REV = "11076708"    # Google "commandlinetools" build number
BUILD_TOOLS = "34.0.0"
ANDROID_PLATFORM = "android-34"
PRESET_NAME = "Android"
APK_NAME = "Kindlewake.apk"

SIDELOAD_KEYSTORE = PROJECT / "tools" / "keys" / "kindlewake-sideload.keystore"
SIDELOAD_ALIAS = "kindlewake"
SIDELOAD_PASS = "kindlewake-sideload"

IS_WIN = os.name == "nt"
IS_LINUX = sys.platform.startswith("linux")
IS_MAC = sys.platform == "darwin"

NETWORK_CLASSES = re.compile(
    r"\b(HTTPRequest|HTTPClient|WebSocketPeer|WebSocketClient|StreamPeerTCP|TCPServer|PacketPeerUDP|UDPServer|"
    r"ENetMultiplayerPeer|ENetConnection|JavaScriptBridge)\b|OS\.shell_open")


class BuildError(Exception):
    """A problem the user can act on; main() prints the message and exits with code 1."""


def say(msg: str = "") -> None:
    print(msg, flush=True)


# --------------------------------------------------------------------------------------------------
# small helpers
# --------------------------------------------------------------------------------------------------
def parse_ver(ver: str) -> Tuple[int, int]:
    m = re.match(r"^(\d+)\.(\d+)", ver)
    if not m:
        raise BuildError("Godot version must look like 4.2.2, got: " + ver)
    return int(m.group(1)), int(m.group(2))


def tools_for_godot(ver: str) -> Tuple[str, str]:
    """(build-tools, platform) needed by the Godot editor's Android export check."""
    if parse_ver(ver) >= (4, 4):
        return "35.0.1", "android-35"
    return BUILD_TOOLS, ANDROID_PLATFORM


def cache_root(arg: Optional[str]) -> Path:
    if arg:
        path = Path(arg).expanduser()
    elif os.environ.get("KINDLEWAKE_CACHE"):
        path = Path(os.environ["KINDLEWAKE_CACHE"]).expanduser()
    else:
        path = Path.home() / ".kindlewake_build"
        if IS_WIN and " " in str(path):
            # the Android command-line tools do not like spaces in their path
            path = Path(os.environ.get("SystemDrive", "C:") + "\\kw_build")
    path.mkdir(parents=True, exist_ok=True)
    return path.resolve()


def exe(name: str) -> str:
    return name + ".exe" if IS_WIN else name


def bat(name: str) -> str:
    return name + ".bat" if IS_WIN else name


def sha256_of(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def write_gdignore(folder: Path) -> None:
    """Godot must never scan big download / output folders."""
    folder.mkdir(parents=True, exist_ok=True)
    (folder / ".gdignore").write_text("", encoding="utf-8")


def rmtree(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path, ignore_errors=True)


# --------------------------------------------------------------------------------------------------
# download + extract
# --------------------------------------------------------------------------------------------------
def download(url: str, dest: Path, what: str) -> None:
    if dest.exists() and dest.stat().st_size > 0:
        return
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_name(dest.name + ".part")
    last: object = None
    for attempt in range(1, 4):
        try:
            say("  downloading " + what + " ...")
            req = urllib.request.Request(url, headers={"User-Agent": "kindlewake-build/1.0"})
            with urllib.request.urlopen(req, timeout=60) as resp, open(tmp, "wb") as out:
                total = int(resp.headers.get("Content-Length") or 0)
                done = 0
                shown = -1
                while True:
                    chunk = resp.read(1 << 20)
                    if not chunk:
                        break
                    out.write(chunk)
                    done += len(chunk)
                    if total:
                        pct = done * 100 // total
                        if pct // 10 != shown:
                            shown = pct // 10
                            say("    %d%% of %.0f MB" % (pct, total / 1e6))
            if total and tmp.stat().st_size != total:
                raise BuildError("incomplete download")
            tmp.replace(dest)
            return
        except (urllib.error.URLError, OSError, BuildError) as err:
            last = err
            say("    attempt %d failed: %s" % (attempt, err))
            time.sleep(3 * attempt)
    raise BuildError("Could not download %s\n  URL: %s\n  Reason: %s\n  Check the internet connection or firewall, "
                     "then run the command again (files that finished downloading are kept)." % (what, url, last))


def extract_zip(archive: Path, dest: Path, only: Optional[callable] = None) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    root = dest.resolve()
    with zipfile.ZipFile(archive) as zf:
        for info in zf.infolist():
            if only is not None and not only(info.filename):
                continue
            target = (dest / info.filename).resolve()
            if root != target and root not in target.parents:
                raise BuildError("Unsafe path inside archive: " + info.filename)
            zf.extract(info, dest)
            mode = (info.external_attr >> 16) & 0o777
            if mode and not info.is_dir():
                os.chmod(target, mode | 0o600)


def extract_tar(archive: Path, dest: Path) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(archive) as tf:
        if hasattr(tarfile, "data_filter"):
            tf.extractall(dest, filter="data")
        else:
            root = dest.resolve()
            for member in tf.getmembers():
                target = (dest / member.name).resolve()
                if root != target and root not in target.parents:
                    raise BuildError("Unsafe path inside archive: " + member.name)
            tf.extractall(dest)


# --------------------------------------------------------------------------------------------------
# running programs
# --------------------------------------------------------------------------------------------------
def run(cmd: List[str], env: Optional[Dict[str, str]] = None, log: Optional[Path] = None, cwd: Optional[Path] = None,
        stdin_text: Optional[str] = None, timeout: Optional[int] = None, show: bool = True) -> Tuple[int, str]:
    """Runs a program, streams its output (console + optional log file), returns (exit code, full output)."""
    use_shell = IS_WIN and cmd[0].lower().endswith((".bat", ".cmd"))
    popen_arg = cmd
    if use_shell:
        # cmd.exe splits unquoted arguments at ';' ("build-tools;34.0.0"), so quote every argument ourselves
        popen_arg = " ".join('"%s"' % a for a in cmd)
    proc = subprocess.Popen(popen_arg, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            stdin=subprocess.PIPE if stdin_text is not None else subprocess.DEVNULL,
                            cwd=str(cwd) if cwd else None, env=env, shell=use_shell,
                            text=True, encoding="utf-8", errors="replace", bufsize=1)
    timer = None
    timed_out = []
    if timeout:
        def kill() -> None:
            timed_out.append(True)
            proc.kill()
        timer = threading.Timer(timeout, kill)
        timer.start()
    if stdin_text is not None and proc.stdin is not None:
        def feed() -> None:
            try:
                proc.stdin.write(stdin_text)
                proc.stdin.close()
            except OSError:
                pass
        threading.Thread(target=feed, daemon=True).start()
    lines: List[str] = []
    assert proc.stdout is not None
    for line in proc.stdout:
        lines.append(line)
        if show:
            sys.stdout.write(line)
            sys.stdout.flush()
    code = proc.wait()
    if timer:
        timer.cancel()
    output = "".join(lines)
    if timed_out:
        output += "\n[build_apk] killed after %d seconds (timeout)\n" % (timeout or 0)
        code = code if code else -9
    if log is not None:
        log.parent.mkdir(parents=True, exist_ok=True)
        log.write_text("$ " + " ".join(cmd) + "\n\n" + output, encoding="utf-8")
    return code, output


# --------------------------------------------------------------------------------------------------
# preflight (offline)
# --------------------------------------------------------------------------------------------------
def parse_cfg(path: Path) -> Dict[str, Dict[str, str]]:
    sections: Dict[str, Dict[str, str]] = {}
    current = ""
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith(";") or line.startswith("#"):
            continue
        if line.startswith("[") and line.endswith("]"):
            current = line[1:-1]
            sections.setdefault(current, {})
        elif "=" in line:
            key, value = line.split("=", 1)
            sections.setdefault(current, {})[key.strip()] = value.strip()
    return sections


def cfg_str(value: Optional[str]) -> str:
    if value is None:
        return ""
    value = value.strip()
    return value[1:-1] if len(value) >= 2 and value[0] == '"' and value[-1] == '"' else value


def png_size(path: Path) -> Optional[Tuple[int, int]]:
    try:
        head = path.read_bytes()[:24]
    except OSError:
        return None
    if head[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    return struct.unpack(">II", head[16:24])


def keystore_settings(project: Optional[Path] = None) -> Tuple[Path, str, str]:
    default = (project / "tools" / "keys" / SIDELOAD_KEYSTORE.name) if project else SIDELOAD_KEYSTORE
    path = Path(os.environ.get("KINDLEWAKE_KEYSTORE") or default)
    alias = os.environ.get("KINDLEWAKE_KEY_ALIAS") or SIDELOAD_ALIAS
    password = os.environ.get("KINDLEWAKE_KEY_PASS") or SIDELOAD_PASS
    return path, alias, password


def preflight(project: Path = PROJECT) -> Tuple[List[str], List[str]]:
    """Returns (errors, warnings). Needs no downloads and no Godot."""
    errors: List[str] = []
    warnings: List[str] = []

    # export preset
    presets_path = project / "export_presets.cfg"
    options: Dict[str, str] = {}
    if not presets_path.exists():
        errors.append("export_presets.cfg is missing (Godot needs it to export).")
    else:
        cfg = parse_cfg(presets_path)
        found = False
        for section, values in cfg.items():
            if re.fullmatch(r"preset\.\d+", section) and cfg_str(values.get("name")) == PRESET_NAME:
                found = True
                if cfg_str(values.get("platform")) != "Android":
                    errors.append('Preset "%s" is not an Android preset.' % PRESET_NAME)
                options = cfg.get(section + ".options", {})
                include = cfg_str(values.get("include_filter"))
                if "*.json" not in include:
                    errors.append('include_filter must contain *.json, otherwise the game data is missing in the APK.')
        if not found:
            errors.append('export_presets.cfg has no preset named "%s".' % PRESET_NAME)
        if options:
            if options.get("gradle_build/use_gradle_build", "false") != "false":
                errors.append("This script builds with export templates; set gradle_build/use_gradle_build=false.")
            if not re.fullmatch(r"([A-Za-z_][A-Za-z0-9_]*\.)+[A-Za-z_][A-Za-z0-9_]*", cfg_str(options.get("package/unique_name"))):
                errors.append("package/unique_name is not a valid Android package name (example: com.kindlewake.game).")
            for key, value in options.items():
                if key.startswith("permissions/") and value == "true":
                    if key == "permissions/internet":
                        errors.append("permissions/internet is true: the game must stay 100% offline.")
                    else:
                        warnings.append("Android permission enabled: " + key)
            if options.get("architectures/arm64-v8a") != "true":
                errors.append("architectures/arm64-v8a must be true (all current phones need it).")
            if options.get("package/signed") != "true":
                warnings.append("package/signed is not true: the APK will not install on most phones.")
            try:
                if int(options.get("version/code", "0")) < 1:
                    raise ValueError
            except ValueError:
                errors.append("version/code must be a whole number >= 1.")
            if not cfg_str(options.get("version/name")):
                errors.append("version/name is empty.")
            sizes = {"launcher_icons/main_192x192": (192, 192),
                     "launcher_icons/adaptive_foreground_432x432": (432, 432),
                     "launcher_icons/adaptive_background_432x432": (432, 432)}
            for key, want in sizes.items():
                value = cfg_str(options.get(key))
                if not value:
                    warnings.append(key + " is empty (Godot's default icon would be used).")
                    continue
                file_path = project / value.replace("res://", "")
                got = png_size(file_path)
                if got is None:
                    errors.append("%s: %s is missing or not a PNG." % (key, value))
                elif got != want:
                    errors.append("%s: %s is %dx%d, needs %dx%d." % (key, value, got[0], got[1], want[0], want[1]))

    # project.godot
    project_file = project / "project.godot"
    if not project_file.exists():
        errors.append("project.godot is missing.")
    else:
        text = project_file.read_text(encoding="utf-8")
        if not re.search(r"^textures/vram_compression/import_etc2_astc\s*=\s*true", text, re.M):
            errors.append("project.godot needs rendering/textures/vram_compression/import_etc2_astc=true "
                          "(Godot refuses Android exports without it).")
        icon = re.search(r'^config/icon\s*=\s*"res://([^"]+)"', text, re.M)
        if not icon or not (project / icon.group(1)).exists():
            errors.append("project.godot config/icon is missing or points to a file that does not exist.")
        orient = re.search(r"^window/handheld/orientation\s*=\s*(\d+)", text, re.M)
        if not orient or int(orient.group(1)) not in (0, 2, 4):
            warnings.append("Screen orientation is not landscape (display/window/handheld/orientation should be 0, 2 or 4).")
        if "gl_compatibility" not in text:
            warnings.append("The GL Compatibility renderer is not set (the project is designed for it).")

    # signing key
    key_path, _alias, _pw = keystore_settings(project)
    if not key_path.exists():
        errors.append("Signing key not found: %s" % key_path)

    # JSON data parses
    data_dir = project / "data"
    if data_dir.exists():
        for path in sorted(data_dir.rglob("*.json")):
            try:
                json.loads(path.read_text(encoding="utf-8"))
            except (ValueError, OSError) as err:
                errors.append("Invalid JSON in %s: %s" % (path.relative_to(project), err))
    else:
        errors.append("data/ folder is missing.")

    # offline guard: no network classes in game scripts
    scripts_dir = project / "scripts"
    if scripts_dir.exists():
        for path in sorted(scripts_dir.rglob("*.gd")):
            for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
                code = line.split("#", 1)[0]
                if NETWORK_CLASSES.search(code):
                    errors.append("%s:%d uses a network API; the game must stay 100%% offline." % (path.relative_to(project), number))
    return errors, warnings


# --------------------------------------------------------------------------------------------------
# toolchain: JDK, Android SDK, Godot
# --------------------------------------------------------------------------------------------------
def valid_jdk(path: Path) -> bool:
    return (path / "bin" / exe("javac")).exists() and (path / "bin" / exe("java")).exists()


def ensure_jdk(cache: Path) -> Path:
    override = os.environ.get("KINDLEWAKE_JAVA_HOME")
    if override and valid_jdk(Path(override)):
        return Path(override)
    jdk = cache / ("jdk" + JDK_FEATURE)
    if valid_jdk(jdk):
        return jdk
    if IS_MAC:
        raise BuildError("macOS is not supported by this script. Use the Godot editor: see docs/BUILD_APK.md, section 'By hand'.")
    machine = os.uname().machine.lower() if hasattr(os, "uname") else os.environ.get("PROCESSOR_ARCHITECTURE", "").lower()
    arch = "aarch64" if machine in ("arm64", "aarch64") else "x64"
    os_name = "windows" if IS_WIN else "linux"
    ext = ".zip" if IS_WIN else ".tar.gz"
    url = "https://api.adoptium.net/v3/binary/latest/%s/ga/%s/%s/jdk/hotspot/normal/eclipse" % (JDK_FEATURE, os_name, arch)
    archive = cache / "downloads" / ("temurin%s-%s-%s%s" % (JDK_FEATURE, os_name, arch, ext))
    download(url, archive, "JDK %s (about 190 MB)" % JDK_FEATURE)
    tmp = cache / "jdk_extract"
    rmtree(tmp)
    if IS_WIN:
        extract_zip(archive, tmp)
    else:
        extract_tar(archive, tmp)
    home = next((p for p in [tmp] + sorted(tmp.rglob("*")) if p.is_dir() and valid_jdk(p)), None)
    if home is None:
        raise BuildError("The downloaded JDK archive has an unexpected layout. Delete %s and try again." % archive)
    rmtree(jdk)
    shutil.move(str(home), str(jdk))
    rmtree(tmp)
    return jdk


def tool_env(jdk: Path, sdk: Optional[Path] = None) -> Dict[str, str]:
    env = dict(os.environ)
    env["JAVA_HOME"] = str(jdk)
    env["PATH"] = str(jdk / "bin") + os.pathsep + env.get("PATH", "")
    if sdk is not None:
        env["ANDROID_HOME"] = str(sdk)
        env["ANDROID_SDK_ROOT"] = str(sdk)
    return env


def ensure_sdk(cache: Path, jdk: Path, godot_ver: str, logs: Path) -> Path:
    build_tools, platform = tools_for_godot(godot_ver)
    sdk = cache / "android-sdk"
    sdkmanager = sdk / "cmdline-tools" / "latest" / "bin" / bat("sdkmanager")
    wanted = [sdk / "platform-tools" / exe("adb"), sdk / "build-tools" / build_tools, sdk / "platforms" / platform]
    if sdkmanager.exists() and all(p.exists() for p in wanted):
        return sdk
    if not sdkmanager.exists():
        if IS_MAC:
            raise BuildError("macOS is not supported by this script.")
        flavour = "win" if IS_WIN else "linux"
        url = "https://dl.google.com/android/repository/commandlinetools-%s-%s_latest.zip" % (flavour, CMDLINE_TOOLS_REV)
        archive = cache / "downloads" / ("commandlinetools-%s-%s.zip" % (flavour, CMDLINE_TOOLS_REV))
        download(url, archive, "Android command-line tools (about 150 MB)")
        tmp = cache / "cmdline_extract"
        rmtree(tmp)
        extract_zip(archive, tmp)
        top = tmp / "cmdline-tools"
        if not (top / "bin").exists():
            raise BuildError("The Android command-line tools archive has an unexpected layout. Delete %s and try again." % archive)
        latest = sdk / "cmdline-tools" / "latest"
        rmtree(latest)
        latest.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(top), str(latest))
        rmtree(tmp)
    env = tool_env(jdk, sdk)
    say("  accepting Android SDK licences ...")
    run([str(sdkmanager), "--sdk_root=" + str(sdk), "--licenses"], env=env, log=logs / "sdk_licenses.txt",
        stdin_text="y\n" * 100, timeout=600, show=False)
    packages = ["platform-tools", "build-tools;" + build_tools, "platforms;" + platform]
    say("  installing Android SDK packages: " + ", ".join(packages) + " (about 150 MB) ...")
    code, _out = run([str(sdkmanager), "--sdk_root=" + str(sdk)] + packages, env=env, log=logs / "sdk_install.txt",
                     stdin_text="y\n" * 20, timeout=1800)
    if code != 0 or not all(p.exists() for p in wanted):
        raise BuildError("Installing the Android SDK failed (see dist/logs/sdk_install.txt). "
                         "Check the internet connection and run the command again.")
    return sdk


def godot_names(ver: str) -> Tuple[str, str]:
    """(executable name inside the zip, zip file name)."""
    if IS_WIN:
        return "Godot_v%s-stable_win64_console.exe" % ver, "Godot_v%s-stable_win64.exe.zip" % ver
    if IS_LINUX:
        return "Godot_v%s-stable_linux.x86_64" % ver, "Godot_v%s-stable_linux.x86_64.zip" % ver
    raise BuildError("macOS is not supported by this script. Use the Godot editor: see docs/BUILD_APK.md, section 'By hand'.")


def ensure_godot(cache: Path, ver: str) -> Path:
    exe_name, zip_name = godot_names(ver)
    base = "https://github.com/godotengine/godot/releases/download/%s-stable/" % ver
    gdir = cache / ("godot-" + ver)
    godot = gdir / exe_name
    if not godot.exists():
        archive = cache / "downloads" / zip_name
        download(base + zip_name, archive, "Godot %s editor (about 60 MB)" % ver)
        rmtree(gdir)
        extract_zip(archive, gdir)
        if not godot.exists():
            raise BuildError("The Godot archive does not contain %s. Delete %s and try again." % (exe_name, archive))
        if not IS_WIN:
            godot.chmod(0o755)
    # "self-contained mode": Godot keeps its settings and templates in editor_data/ next to the program
    (gdir / "_sc_").write_text("", encoding="utf-8")
    templates_root = gdir / "editor_data" / "export_templates"
    if not any(templates_root.glob("*/android_release.apk")):
        tpz_name = "Godot_v%s-stable_export_templates.tpz" % ver
        tpz = cache / "downloads" / tpz_name
        download(base + tpz_name, tpz, "Godot %s export templates (about 800 MB, once)" % ver)
        with zipfile.ZipFile(tpz) as zf:
            try:
                version_dir = zf.read("templates/version.txt").decode("utf-8").strip()
            except KeyError:
                raise BuildError("The export templates file has an unexpected layout. Delete %s and try again." % tpz)
        dest = templates_root / version_dir
        rmtree(dest)
        dest.mkdir(parents=True, exist_ok=True)
        wanted = re.compile(r"^templates/(android_[^/]+|version\.txt)$")
        with zipfile.ZipFile(tpz) as zf:
            for info in zf.infolist():
                if wanted.match(info.filename):
                    with zf.open(info) as src, open(dest / Path(info.filename).name, "wb") as out:
                        shutil.copyfileobj(src, out)
        if not (dest / "android_release.apk").exists():
            raise BuildError("android_release.apk was not found in the export templates. Delete %s and try again." % tpz)
    return godot


def write_editor_settings(godot: Path, ver: str, sdk: Path, jdk: Path) -> None:
    key_path, alias, password = keystore_settings()
    lines = [
        "[gd_resource type=\"EditorSettings\" format=3]",
        "",
        "[resource]",
        'export/android/android_sdk_path = "%s"' % sdk.as_posix(),
        'export/android/java_sdk_path = "%s"' % jdk.as_posix(),
        'export/android/debug_keystore = "%s"' % key_path.resolve().as_posix(),
        'export/android/debug_keystore_user = "%s"' % alias,
        'export/android/debug_keystore_pass = "%s"' % password,
        "export/android/shutdown_adb_on_exit = true",
        "",
    ]
    major, minor = parse_ver(ver)
    data_dir = godot.parent / "editor_data"
    data_dir.mkdir(parents=True, exist_ok=True)
    for name in {"editor_settings-4.tres", "editor_settings-%d.%d.tres" % (major, minor)}:
        (data_dir / name).write_text("\n".join(lines), encoding="utf-8")


def godot_env(jdk: Path, sdk: Path) -> Dict[str, str]:
    env = tool_env(jdk, sdk)
    key_path, alias, password = keystore_settings()
    for kind in ("RELEASE", "DEBUG"):
        env["GODOT_ANDROID_KEYSTORE_%s_PATH" % kind] = str(key_path.resolve())
        env["GODOT_ANDROID_KEYSTORE_%s_USER" % kind] = alias
        env["GODOT_ANDROID_KEYSTORE_%s_PASSWORD" % kind] = password
    return env


# --------------------------------------------------------------------------------------------------
# APK verification
# --------------------------------------------------------------------------------------------------
def verify_apk(apk: Path, sdk: Path, jdk: Path, godot_ver: str, allow_internet: bool) -> List[str]:
    """Returns report lines. Raises BuildError if the APK is broken or asks for the INTERNET permission."""
    report: List[str] = []
    if not apk.exists() or apk.stat().st_size < 1_000_000:
        raise BuildError("The export did not produce a usable APK at %s (see dist/logs/export.txt)." % apk)
    with zipfile.ZipFile(apk) as zf:
        bad = zf.testzip()
        if bad:
            raise BuildError("The APK is corrupt (bad entry %s)." % bad)
        names = set(zf.namelist())
    if "AndroidManifest.xml" not in names:
        raise BuildError("The APK has no AndroidManifest.xml.")
    if "classes.dex" not in names:
        report.append("note: classes.dex not found in the APK (unexpected for a Godot template).")
    libs = sorted({n.split("/")[1] for n in names if n.startswith("lib/") and n.count("/") >= 2})
    report.append("native libraries for: " + (", ".join(libs) if libs else "NONE (unexpected)"))
    if "arm64-v8a" not in libs:
        raise BuildError("The APK has no arm64-v8a library, so it would not run on modern phones.")
    build_tools, _platform = tools_for_godot(godot_ver)
    bt_dir = sdk / "build-tools" / build_tools
    env = tool_env(jdk, sdk)
    aapt2 = bt_dir / exe("aapt2")
    if aapt2.exists():
        code, out = run([str(aapt2), "dump", "permissions", str(apk)], env=env, show=False)
        perms = re.findall(r"uses-permission(?:-sdk-23)?: name='([^']+)'", out)
        report.append("permissions requested: " + (", ".join(perms) if perms else "none"))
        if code == 0 and "android.permission.INTERNET" in perms and not allow_internet:
            raise BuildError("The APK requests the INTERNET permission, but Kindlewake must be 100% offline. "
                             "Check export_presets.cfg (permissions/internet=false) and the build log.")
    else:
        report.append("warning: aapt2 not found, permissions were not checked.")
    signer = bt_dir / bat("apksigner")
    if signer.exists():
        code, out = run([str(signer), "verify", "--print-certs", str(apk)], env=env, show=False)
        if code != 0:
            raise BuildError("apksigner says the APK signature is not valid:\n" + out.strip())
        digest = re.search(r"certificate SHA-256 digest: (\w+)", out)
        report.append("signature: valid" + (" (key SHA-256 %s...)" % digest.group(1)[:16] if digest else ""))
    else:
        report.append("warning: apksigner not found, the signature was not checked.")
    return report


def summarize_test_output(output: str) -> Dict[str, int]:
    return {
        "FAIL": len(re.findall(r"^\s*FAIL\b", output, re.M)),
        "SCRIPT ERROR": len(re.findall(r"SCRIPT ERROR", output)),
        "Parse Error": len(re.findall(r"Parse Error", output)),
    }


# --------------------------------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------------------------------
def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Build the Kindlewake Android APK.")
    parser.add_argument("--check", action="store_true", help="offline preflight only, no downloads, no Godot")
    parser.add_argument("--skip-tests", action="store_true", help="do not run tests/run_tests.gd")
    parser.add_argument("--strict", action="store_true", help="fail the build when the tests report problems")
    parser.add_argument("--with-balance", action="store_true", help="also run tests/balance_report.gd")
    parser.add_argument("--debug", action="store_true", help="export a debug build instead of a release build")
    parser.add_argument("--install", action="store_true", help="adb install -r the APK on a USB-connected phone")
    parser.add_argument("--allow-internet", action="store_true", help="do not fail if the APK requests INTERNET")
    parser.add_argument("--godot", default=GODOT_VERSION, help="Godot version (default %s)" % GODOT_VERSION)
    parser.add_argument("--cache", default=None, help="download/cache folder (default ~/.kindlewake_build)")
    args = parser.parse_args(argv)

    try:
        sys.stdout.reconfigure(errors="replace")  # type: ignore[attr-defined]
    except (AttributeError, ValueError):
        pass

    started = time.time()
    dist = PROJECT / "dist"
    logs = dist / "logs"
    summary: List[str] = []

    say("Kindlewake APK builder (Godot %s)" % args.godot)
    say("\n[1] Preflight checks (offline)")
    errors, warnings = preflight(PROJECT)
    for w in warnings:
        say("  warning: " + w)
    for e in errors:
        say("  ERROR: " + e)
    if errors:
        say("\nFix the errors above and run again.")
        return 1
    say("  ok: preset, project settings, icons, signing key, data files, offline guard")
    if args.check:
        say("\nPreflight passed. Run without --check to build the APK.")
        return 0

    try:
        if IS_MAC:
            raise BuildError("macOS is not supported by this script. Use the Godot editor: see docs/BUILD_APK.md, section 'By hand'.")
        cache = cache_root(args.cache)
        write_gdignore(dist)
        logs.mkdir(parents=True, exist_ok=True)
        write_gdignore(cache)
        say("\n[2] Tools (cached in %s)" % cache)
        jdk = ensure_jdk(cache)
        say("  JDK ok: " + str(jdk))
        sdk = ensure_sdk(cache, jdk, args.godot, logs)
        say("  Android SDK ok: " + str(sdk))
        godot = ensure_godot(cache, args.godot)
        say("  Godot ok: " + str(godot))
        write_editor_settings(godot, args.godot, sdk, jdk)
        env = godot_env(jdk, sdk)

        say("\n[3] Importing the project")
        # Run the editor scan first so Godot 4.2 builds its global script-class
        # registry (class_name types) before autoloads and --script tests compile.
        code, out = run([str(godot), "--headless", "--editor", "--path", str(PROJECT), "--quit-after", "120"], env=env,
                        log=logs / "import-pass-1.txt", timeout=900)
        scan_errors = ("Parse Error" in out or "SCRIPT ERROR: Compile Error" in out or "Failed to load script" in out)
        if code != 0 or scan_errors:
            say("  first editor scan reported script-registration/import problems; running a clean second scan ...")
            code, out = run([str(godot), "--headless", "--editor", "--path", str(PROJECT), "--quit-after", "120"], env=env,
                            log=logs / "import.txt", timeout=900)
        remaining_scan_errors = ("Parse Error" in out or "SCRIPT ERROR: Compile Error" in out or "Failed to load script" in out)
        summary.append("import: exit %d, script errors %s" % (code, "yes" if remaining_scan_errors else "no"))
        if code != 0 or remaining_scan_errors:
            raise BuildError("Godot editor import still reports script errors after two scans. See dist/logs/import.txt.")

        say("\n[4] Loading every authored scene in headless mode")
        code, out = run([str(godot), "--headless", "--path", str(PROJECT), "--script", "res://tests/scene_smoke_test.gd"],
                        env=env, log=logs / "scene_smoke_test.txt", timeout=300)
        summary.append("scene_smoke: exit %d, loaded %s" %
                       (code, re.search(r"Scene smoke: (.*)", out).group(1) if re.search(r"Scene smoke: (.*)", out) else "unknown"))
        if code != 0 or "SCRIPT ERROR" in out or "Parse Error" in out:
            raise BuildError("Headless scene smoke test failed. See dist/logs/scene_smoke_test.txt.")

        if not args.skip_tests:
            say("\n[5] Running tests/run_tests.gd (output is saved; it does not block the APK unless --strict)")
            code, out = run([str(godot), "--headless", "--path", str(PROJECT), "--script", "res://tests/run_tests.gd"],
                            env=env, log=logs / "run_tests.txt", timeout=1800)
            counts = summarize_test_output(out)
            summary.append("run_tests: exit %d, FAIL %d, SCRIPT ERROR %d, Parse Error %d" %
                           (code, counts["FAIL"], counts["SCRIPT ERROR"], counts["Parse Error"]))
            if code != 0 or any(counts.values()):
                say("\n  TESTS REPORTED PROBLEMS: " + summary[-1])
                say("  Full output: dist/logs/run_tests.txt (paste it into the next chat).")
                if args.strict:
                    raise BuildError("Tests failed and --strict was given.")

            lifecycle_scene = PROJECT / "tests" / "campaign_continue_lifecycle_test.tscn"
            if lifecycle_scene.is_file():
                say("\n[5a] Running campaign save/restore and World startup lifecycle test")
                code, out = run([str(godot), "--headless", "--path", str(PROJECT),
                                 "res://tests/campaign_continue_lifecycle_test.tscn"],
                                env=env, log=logs / "campaign_continue_lifecycle_test.txt", timeout=300)
                lifecycle_ok = ("Campaign lifecycle failures: 0" in out and
                                "SCRIPT ERROR" not in out and "Parse Error" not in out)
                summary.append("campaign_lifecycle: exit %d, pass marker %s" %
                               (code, "yes" if lifecycle_ok else "no"))
                if code != 0 or not lifecycle_ok:
                    say("  CAMPAIGN LIFECYCLE TEST FAILED. See dist/logs/campaign_continue_lifecycle_test.txt.")
                    if args.strict:
                        raise BuildError("Campaign continue runtime lifecycle test failed.")

            if args.with_balance:
                say("\n    Running tests/balance_report.gd")
                code, out = run([str(godot), "--headless", "--path", str(PROJECT), "--script", "res://tests/balance_report.gd"],
                                env=env, log=logs / "balance_report.txt", timeout=3600)
                summary.append("balance_report: exit %d" % code)

        say("\n[6] Exporting the APK")
        apk = dist / APK_NAME
        if apk.exists():
            apk.unlink()
        flag = "--export-debug" if args.debug else "--export-release"
        code, out = run([str(godot), "--headless", "--path", str(PROJECT), flag, PRESET_NAME, str(apk)], env=env,
                        log=logs / "export.txt", timeout=1800)
        if code != 0 or not apk.exists():
            hint = ""
            if "No export template" in out or "export template" in out.lower():
                hint = "\n  Hint: the export templates were not found. Delete the godot-%s folder inside %s and run again." % (args.godot, cache)
            raise BuildError("Godot could not export the APK (exit %d). See dist/logs/export.txt, paste the last lines "
                             "into the chat.%s" % (code, hint))

        say("\n[6] Verifying the APK")
        report = verify_apk(apk, sdk, jdk, args.godot, args.allow_internet)
        for line in report:
            say("  " + line)
        size_mb = apk.stat().st_size / 1e6
        summary.append("APK: dist/%s, %.1f MB, sha256 %s" % (APK_NAME, size_mb, sha256_of(apk)[:16]))
        summary.extend(report)

        if args.install:
            say("\n[7] Installing on the connected phone (USB debugging must be on)")
            adb = sdk / "platform-tools" / exe("adb")
            code, _o = run([str(adb), "install", "-r", str(apk)], env=env, log=logs / "adb_install.txt", timeout=300)
            summary.append("adb install: exit %d" % code)

        write_summary(logs, args, summary, time.time() - started)
        say("\nDONE in %d s. Your installer: %s (%.1f MB)" % (time.time() - started, apk, size_mb))
        say("Copy it to your phone and tap it. Step by step: docs/BUILD_APK.md ('Install on the phone').")
        return 0
    except BuildError as err:
        summary.append("FAILED: " + str(err).splitlines()[0])
        try:
            write_summary(logs, args, summary, time.time() - started)
        except OSError:
            pass
        say("\nBUILD FAILED: " + str(err))
        return 1


def write_summary(logs: Path, args: argparse.Namespace, summary: List[str], seconds: float) -> None:
    logs.mkdir(parents=True, exist_ok=True)
    lines = ["Kindlewake build summary", "godot: " + args.godot, "seconds: %d" % seconds, "platform: " + sys.platform] + summary
    (logs / "BUILD_SUMMARY.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")
    write_ci_summary(logs)


def write_ci_summary(logs: Path) -> None:
    """On GitHub Actions only: show the results on the run page (the 'Summary' section), so nobody has to download
    the log files. Does nothing anywhere else. Never raises."""
    target = os.environ.get("GITHUB_STEP_SUMMARY")
    if not target:
        return

    def read(name: str) -> List[str]:
        try:
            text = (logs / name).read_text(encoding="utf-8", errors="replace")
        except OSError:
            return []
        return [ln[:300] for ln in text.splitlines()]

    pattern = re.compile(r"^\s*FAIL\b|SCRIPT ERROR|Parse Error|ERROR:")

    def problems(lines: List[str]) -> List[str]:
        """Matching lines, plus the 'at: file:line' line Godot prints right after a script error."""
        found: List[str] = []
        for i, ln in enumerate(lines):
            if pattern.search(ln):
                found.append(ln)
                if i + 1 < len(lines) and lines[i + 1].lstrip().startswith("at:"):
                    found.append(lines[i + 1])
        return found

    def block(title: str, lines: List[str]) -> List[str]:
        return ["", "### " + title, "```", "\n".join(lines) if lines else "(nothing)", "```"]

    out: List[str] = ["## Kindlewake build report"]
    build = read("BUILD_SUMMARY.txt")
    out += block("Build summary", build)
    smoke = read("scene_smoke_test.txt")
    if smoke:
        hits = problems(smoke)
        out += block("Scene smoke problems (%d line(s); first 80 shown)" % len(hits), hits[:80] or ["none"])
        out += block("Scene smoke summary", smoke[-25:])
    tests = read("run_tests.txt")
    if tests:
        hits = problems(tests)
        out += block("Test problems (%d line(s); first 80 shown)" % len(hits), hits[:80] or ["none"])
        out += block("Last 40 lines of the test output", tests[-40:])
    imported = problems(read("import.txt"))
    if imported:
        out += block("Import problems (first 40)", imported[:40])
    if any(ln.startswith("FAILED") for ln in build):
        for name in ("export.txt", "sdk_install.txt"):
            tail = read(name)
            if tail:
                out += block("Last 30 lines of " + name, tail[-30:])
    try:
        with open(target, "a", encoding="utf-8") as fh:
            fh.write("\n".join(out) + "\n")
    except OSError:
        pass


if __name__ == "__main__":
    sys.exit(main())
