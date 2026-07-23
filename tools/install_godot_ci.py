from __future__ import annotations

import argparse
import os
import shutil
import stat
import sys
import urllib.request
import zipfile
from pathlib import Path


def platform_asset(version: str) -> tuple[str, str]:
    if sys.platform.startswith("linux"):
        return (
            f"Godot_v{version}-stable_linux.x86_64.zip",
            f"Godot_v{version}-stable_linux.x86_64",
        )
    if sys.platform == "win32":
        return (
            f"Godot_v{version}-stable_win64.exe.zip",
            f"Godot_v{version}-stable_win64.exe",
        )
    raise RuntimeError(f"Unsupported CI platform: {sys.platform}")


def download(url: str, destination: Path) -> None:
    request = urllib.request.Request(url, headers={"User-Agent": "ten-paces-ci"})
    with urllib.request.urlopen(request, timeout=120) as response, destination.open("wb") as output:
        shutil.copyfileobj(response, output)


def install(version: str, destination: Path) -> Path:
    asset, executable_name = platform_asset(version)
    executable = destination / executable_name
    if executable.is_file():
        return executable.resolve()

    destination.mkdir(parents=True, exist_ok=True)
    archive = destination / asset
    url = f"https://github.com/godotengine/godot/releases/download/{version}-stable/{asset}"
    print(f"Downloading Godot {version} from {url}")
    download(url, archive)
    with zipfile.ZipFile(archive) as bundle:
        bundle.extractall(destination)
    archive.unlink(missing_ok=True)

    if not executable.is_file():
        matches = list(destination.rglob(executable_name))
        if len(matches) != 1:
            raise RuntimeError(f"Godot executable not found after extraction: {executable_name}")
        executable = matches[0]

    if not sys.platform == "win32":
        executable.chmod(executable.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    return executable.resolve()


def write_github_output(path: Path, github_output: str | None) -> None:
    print(f"Godot executable: {path}")
    if github_output:
        with Path(github_output).open("a", encoding="utf-8") as handle:
            handle.write(f"godot_path={path}\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Install an official Godot CI binary.")
    parser.add_argument("--version", default="4.7.1")
    parser.add_argument("--destination", default=".ci/godot")
    parser.add_argument("--github-output", default=os.environ.get("GITHUB_OUTPUT"))
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    executable = install(args.version, Path(args.destination).resolve())
    write_github_output(executable, args.github_output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
