from __future__ import annotations

import argparse
import hashlib
import json
import re
import secrets
import shutil
import struct
import sys
import tempfile
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


CAPTURE_ID_RE = re.compile(r"^TEN-RVC-\d{8}-\d{3}$")
CAPTURE_RUN_ID_RE = re.compile(r"^TEN-RVC-RUN-\d{8}-\d{3}$")
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$", re.IGNORECASE)
NONCE_RE = re.compile(r"^[0-9a-f]{32}$")
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
MANIFEST_ROLE = "TEN_RUNTIME_VISUAL_CAPTURE_MANIFEST"
FRESHNESS_RECEIPT_ROLE = "TEN_RUNTIME_VISUAL_CAPTURE_FRESHNESS_RECEIPT"
FRESHNESS_MODE = "PREPARED_ABSENT_THEN_PRESENT"
FRESHNESS_CLAIM_CEILING = (
    "SAME_RUN_PATH_FRESHNESS_NOT_PRODUCER_AUTHENTICITY_OR_VISUAL_QUALITY"
)
MAX_IMAGE_BYTES = 15 * 1024 * 1024


class CaptureValidationError(ValueError):
    pass


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_relative_repository_path(value: str, *, label: str) -> str:
    candidate = Path(value)
    if not value or candidate.is_absolute() or ".." in candidate.parts:
        raise CaptureValidationError(f"{label} must be a non-empty repository-relative path")
    return candidate.as_posix()


def validate_commit(value: str, *, label: str) -> str:
    if not COMMIT_RE.fullmatch(value):
        raise CaptureValidationError(f"{label} must be an exact 40-character Git SHA")
    return value.lower()


def validate_capture_run_id(value: str) -> str:
    if not CAPTURE_RUN_ID_RE.fullmatch(value):
        raise CaptureValidationError(
            "capture run ID must match TEN-RVC-RUN-YYYYMMDD-NNN"
        )
    return value


def inspect_png(path: Path) -> tuple[int, int, int, str]:
    if not path.is_file():
        raise CaptureValidationError(f"source image does not exist: {path}")
    byte_count = path.stat().st_size
    if byte_count <= 0 or byte_count > MAX_IMAGE_BYTES:
        raise CaptureValidationError(f"source image size must be between 1 and {MAX_IMAGE_BYTES} bytes")

    with path.open("rb") as handle:
        header = handle.read(33)
    if len(header) < 33 or header[:8] != PNG_SIGNATURE:
        raise CaptureValidationError("source image must be a PNG with a valid signature and IHDR header")
    if header[12:16] != b"IHDR" or header[8:12] != b"\x00\x00\x00\x0d":
        raise CaptureValidationError("source image must be a PNG with a valid IHDR chunk")
    width, height = struct.unpack(">II", header[16:24])
    if width <= 0 or height <= 0:
        raise CaptureValidationError("source image must have positive PNG dimensions")
    return width, height, byte_count, sha256_file(path)


def load_manifest(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {
            "schema_version": 1,
            "manifest_role": MANIFEST_ROLE,
            "retention_policy": "MINIMUM_REPRESENTATIVE_CAPTURE_SET",
            "captures": [],
        }
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise CaptureValidationError(f"manifest is not valid JSON: {path}") from exc
    if not isinstance(manifest, dict) or manifest.get("manifest_role") != MANIFEST_ROLE:
        raise CaptureValidationError(f"manifest role mismatch: {path}")
    if manifest.get("schema_version") != 1 or not isinstance(manifest.get("captures"), list):
        raise CaptureValidationError(f"manifest schema mismatch: {path}")
    return manifest


def atomic_write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        newline="\n",
        dir=path.parent,
        delete=False,
        prefix=f".{path.stem}.",
        suffix=".tmp",
    ) as temporary:
        json.dump(payload, temporary, ensure_ascii=False, indent=2)
        temporary.write("\n")
        temporary_path = Path(temporary.name)
    temporary_path.replace(path)


def prepare_freshness_receipt(
    *,
    project_root: Path,
    source_image: Path,
    receipt_path: Path,
    capture_run_id: str,
    source_commit: str,
) -> dict[str, Any]:
    root = project_root.resolve()
    source = source_image.resolve()
    receipt = receipt_path.resolve()
    if not root.is_dir():
        raise CaptureValidationError(f"project root does not exist: {root}")
    normalized_commit = validate_commit(source_commit, label="source commit")
    normalized_run_id = validate_capture_run_id(capture_run_id)
    if source == receipt:
        raise CaptureValidationError("freshness receipt cannot use the source image path")
    if source.exists():
        raise CaptureValidationError(
            "source image already exists before capture preparation; remove or isolate stale transient output first"
        )
    if receipt.exists():
        raise CaptureValidationError(
            f"freshness receipt already exists and cannot be reused: {receipt}"
        )

    payload = {
        "schema_version": 1,
        "receipt_role": FRESHNESS_RECEIPT_ROLE,
        "capture_run_id": normalized_run_id,
        "source_commit": normalized_commit,
        "project_root": str(root),
        "source_image": str(source),
        "source_absent_at_prepare": True,
        "prepared_at_utc": datetime.now(UTC).isoformat(),
        "receipt_nonce": secrets.token_hex(16),
    }
    atomic_write_json(receipt, payload)
    if source.exists():
        receipt.unlink(missing_ok=True)
        raise CaptureValidationError(
            "source image appeared during capture preparation; use a new run identity and retry"
        )
    return payload


def load_freshness_receipt(path: Path) -> tuple[dict[str, Any], str]:
    receipt = path.resolve()
    if not receipt.is_file():
        raise CaptureValidationError(f"freshness receipt does not exist: {receipt}")
    try:
        raw = receipt.read_bytes()
        payload = json.loads(raw.decode("utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise CaptureValidationError(
            f"freshness receipt is not valid UTF-8 JSON: {receipt}"
        ) from exc
    if not isinstance(payload, dict):
        raise CaptureValidationError("freshness receipt must be a JSON object")
    if payload.get("schema_version") != 1:
        raise CaptureValidationError("freshness receipt schema_version must be 1")
    if payload.get("receipt_role") != FRESHNESS_RECEIPT_ROLE:
        raise CaptureValidationError("freshness receipt role mismatch")
    return payload, hashlib.sha256(raw).hexdigest()


def validate_freshness_receipt(
    *,
    receipt_path: Path,
    project_root: Path,
    source_image: Path,
    capture_run_id: str,
    source_commit: str,
    expected_source_commit: str,
) -> dict[str, Any]:
    root = project_root.resolve()
    source = source_image.resolve()
    normalized_run_id = validate_capture_run_id(capture_run_id)
    normalized_commit = validate_commit(source_commit, label="source commit")
    normalized_expected = validate_commit(
        expected_source_commit, label="expected source commit"
    )
    if normalized_commit != normalized_expected:
        raise CaptureValidationError(
            "source commit does not match the trusted expected source commit"
        )

    receipt, receipt_digest = load_freshness_receipt(receipt_path)
    if receipt.get("project_root") != str(root):
        raise CaptureValidationError("freshness receipt project root mismatch")
    if receipt.get("capture_run_id") != normalized_run_id:
        raise CaptureValidationError("freshness receipt capture run ID mismatch")
    if receipt.get("source_commit") != normalized_commit:
        raise CaptureValidationError("freshness receipt source commit mismatch")
    if receipt.get("source_image") != str(source):
        raise CaptureValidationError("freshness receipt source image path mismatch")
    if receipt.get("source_absent_at_prepare") is not True:
        raise CaptureValidationError(
            "freshness receipt does not prove source absence at preparation"
        )
    prepared_at = receipt.get("prepared_at_utc")
    if not isinstance(prepared_at, str) or not prepared_at.strip():
        raise CaptureValidationError("freshness receipt prepared_at_utc is required")
    nonce = receipt.get("receipt_nonce")
    if not isinstance(nonce, str) or not NONCE_RE.fullmatch(nonce):
        raise CaptureValidationError("freshness receipt nonce is malformed")
    if not source.is_file():
        raise CaptureValidationError(
            "current capture run did not create the expected source image"
        )
    return {
        "mode": FRESHNESS_MODE,
        "capture_run_id": normalized_run_id,
        "prepared_at_utc": prepared_at,
        "source_absent_at_prepare": True,
        "trusted_source_identity_match": True,
        "receipt_nonce": nonce,
        "receipt_sha256": receipt_digest,
        "claim_ceiling": FRESHNESS_CLAIM_CEILING,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Register a repository-controlled Godot runtime visual capture without upgrading Human/device evidence."
    )
    parser.add_argument("--project-root", required=True, type=Path)
    parser.add_argument("--source-image", required=True, type=Path)
    parser.add_argument("--capture-id", required=True)
    parser.add_argument("--capture-run-id", required=True)
    parser.add_argument("--freshness-receipt", required=True, type=Path)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--expected-source-commit", required=True)
    parser.add_argument("--scene-path", required=True)
    parser.add_argument("--capture-state", required=True)
    parser.add_argument("--entry-route", required=True)
    parser.add_argument("--work-item-id", required=True)
    parser.add_argument("--consumer", required=True, action="append")
    parser.add_argument("--diagnostics-errors", required=True, type=int)
    parser.add_argument("--diagnostics-warnings", required=True, type=int)
    parser.add_argument("--source-delta", default="NOT_RECORDED")
    parser.add_argument("--allow-additional-state", action="store_true")
    parser.add_argument("--additional-state-reason", default="")
    return parser


def register_capture(args: argparse.Namespace) -> dict[str, Any]:
    root = args.project_root.resolve()
    source = args.source_image.resolve()
    if not root.is_dir():
        raise CaptureValidationError(f"project root does not exist: {root}")
    if not CAPTURE_ID_RE.fullmatch(args.capture_id):
        raise CaptureValidationError("capture ID must match TEN-RVC-YYYYMMDD-NNN")
    normalized_source_commit = validate_commit(
        args.source_commit, label="source commit"
    )
    freshness = validate_freshness_receipt(
        receipt_path=args.freshness_receipt,
        project_root=root,
        source_image=source,
        capture_run_id=args.capture_run_id,
        source_commit=normalized_source_commit,
        expected_source_commit=args.expected_source_commit,
    )
    if not args.scene_path.startswith("res://") or ".." in Path(args.scene_path.removeprefix("res://")).parts:
        raise CaptureValidationError("scene path must be a safe res:// path")
    if not args.capture_state.strip() or not args.entry_route.strip() or not args.work_item_id.strip():
        raise CaptureValidationError("capture state, entry route, and work item ID are required")
    if args.diagnostics_errors < 0 or args.diagnostics_warnings < 0:
        raise CaptureValidationError("diagnostics counts cannot be negative")
    consumers = [validate_relative_repository_path(value, label="consumer") for value in args.consumer]
    for consumer in consumers:
        if not (root / consumer).is_file():
            raise CaptureValidationError(f"consumer does not exist as a repository file: {consumer}")
    width, height, byte_count, digest = inspect_png(source)

    evidence_root = root / "docs" / "evidence"
    capture_dir = evidence_root / "runtime-captures"
    manifest_path = evidence_root / "RUNTIME_VISUAL_CAPTURE_MANIFEST.json"
    manifest = load_manifest(manifest_path)
    existing_ids = {entry.get("capture_id") for entry in manifest["captures"] if isinstance(entry, dict)}
    if args.capture_id in existing_ids:
        raise CaptureValidationError(f"capture ID already exists: {args.capture_id}")
    existing_receipt_nonces = {
        entry.get("freshness", {}).get("receipt_nonce")
        for entry in manifest["captures"]
        if isinstance(entry, dict) and isinstance(entry.get("freshness"), dict)
    }
    if freshness["receipt_nonce"] in existing_receipt_nonces:
        raise CaptureValidationError("freshness receipt was already consumed by another capture")

    same_work_item = [
        entry for entry in manifest["captures"]
        if isinstance(entry, dict) and entry.get("work_item_id") == args.work_item_id
    ]
    if len(same_work_item) >= 2 and not args.allow_additional_state:
        raise CaptureValidationError(
            "a third capture for the same work item requires --allow-additional-state and --additional-state-reason"
        )
    if args.allow_additional_state and not args.additional_state_reason.strip():
        raise CaptureValidationError("--allow-additional-state requires --additional-state-reason")

    capture_dir.mkdir(parents=True, exist_ok=True)
    target = capture_dir / f"{args.capture_id}.png"
    if target.exists():
        raise CaptureValidationError(f"capture target already exists: {target}")
    try:
        source.relative_to(capture_dir.resolve())
    except ValueError:
        pass
    else:
        raise CaptureValidationError("source image cannot already be inside the runtime capture directory")

    entry: dict[str, Any] = {
        "capture_id": args.capture_id,
        "recorded_at_utc": datetime.now(UTC).isoformat(),
        "work_item_id": args.work_item_id,
        "source_commit": normalized_source_commit,
        "runtime": {
            "scene_path": args.scene_path,
            "capture_state": args.capture_state,
            "entry_route": args.entry_route,
            "source_delta": args.source_delta,
        },
        "consumers": consumers,
        "diagnostics": {
            "error_count": args.diagnostics_errors,
            "warning_count": args.diagnostics_warnings,
        },
        "image": {
            "path": target.relative_to(root).as_posix(),
            "sha256": digest,
            "bytes": byte_count,
            "format": "PNG",
            "width": width,
            "height": height,
        },
        "freshness": freshness,
        "evidence_level": "MACHINE_RUNTIME_CAPTURE",
        "evidence_ceiling": {
            "human_usability": "NOT_RUN",
            "android_actual_device": "NOT_RUN",
            "accessibility_user": "NOT_RUN",
            "release_performance": "NOT_RUN",
        },
    }
    if args.allow_additional_state:
        entry["additional_state_reason"] = args.additional_state_reason.strip()

    shutil.copyfile(source, target)
    try:
        if sha256_file(target) != digest:
            raise CaptureValidationError("copied capture hash does not match source hash")
        manifest["captures"].append(entry)
        atomic_write_json(manifest_path, manifest)
    except Exception:
        target.unlink(missing_ok=True)
        raise
    return entry


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        entry = register_capture(args)
    except CaptureValidationError as exc:
        print(f"runtime visual capture rejected: {exc}", file=sys.stderr)
        return 2
    print(json.dumps({"capture_id": entry["capture_id"], "image": entry["image"]}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
