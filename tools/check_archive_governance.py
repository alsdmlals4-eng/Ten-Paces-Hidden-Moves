#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_BASE_COMMIT = "6a224e450f9420223c00921f3c56e051612f92ad"
ADAPTER = Path("[기획서]/00_프로젝트_허브/ARCHIVE_RETENTION_ADAPTER.json")
MANIFEST = Path("docs/archive/MANIFEST.json")
ROUTES = Path("skills/BASE_SHARED_SKILL_ROUTES.json")
PROJECT_ADAPTER = Path("skills/PROJECT_BASE_SKILL_ADAPTER.json")
REGISTRY = Path("[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json")
CLASSIFICATIONS = {"CURRENT_AUTHORITY", "COMPATIBILITY_ONLY", "ARCHIVE_HISTORY", "EVIDENCE_RETENTION", "GENERATED_DERIVATIVE", "DELETE_PROHIBITED_SECRET", "DELETE_APPROVED", "KEEP_UNRESOLVED"}
STATUSES = {"PASS", "PARTIAL", "FAIL", "NOT_RUN"}
SECRET_PATTERNS = (
    re.compile(r"ghp_[A-Za-z0-9]{20,}"),
    re.compile(r"github_pat_[A-Za-z0-9_]{20,}"),
    re.compile(r"sk-[A-Za-z0-9]{20,}"),
    re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
)


def _load(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"JSON root must be object: {path}")
    return value


def _safe(value: str) -> bool:
    path = PurePosixPath(value)
    return bool(value) and not path.is_absolute() and ".." not in path.parts


def _body(text: str) -> str:
    if text.startswith("---\n"):
        end = text.find("\n---\n", 4)
        if end >= 0:
            text = text[end + 5 :]
    return text.strip()


def validate(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    try:
        adapter = _load(root / ADAPTER)
        manifest = _load(root / MANIFEST)
        routes = _load(root / ROUTES)
        project_adapter = _load(root / PROJECT_ADAPTER)
        registry = _load(root / REGISTRY)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        return [f"parse failure: {error}"]

    if adapter.get("adapter_role") != "legacy-retention-archive-project-adapter":
        errors.append("invalid archive adapter identity")
    if adapter.get("base", {}).get("commit") != EXPECTED_BASE_COMMIT:
        errors.append("archive adapter Base commit mismatch")
    if adapter.get("project", {}).get("repository") != "alsdmlals4-eng/Ten-Paces-Hidden-Moves":
        errors.append("archive adapter project mismatch")
    expected_policies = {
        "preserve_original_content": True,
        "blank_placeholders_allowed": False,
        "secrets_may_be_archived": False,
        "default_active_authority": False,
        "default_implementation_authority": "NONE",
    }
    for key, expected in expected_policies.items():
        if adapter.get("policies", {}).get(key) != expected:
            errors.append(f"unsafe archive policy: {key}")

    if routes.get("base", {}).get("commit") != EXPECTED_BASE_COMMIT:
        errors.append("shared route Base commit mismatch")
    if project_adapter.get("base", {}).get("commit") != EXPECTED_BASE_COMMIT:
        errors.append("project adapter Base commit mismatch")
    route = routes.get("routes", {}).get("legacy_retention_and_archives", {})
    if route.get("skill_id") != "governing-legacy-retention-and-archives" or route.get("adapter") != ADAPTER.as_posix():
        errors.append("legacy retention shared route mismatch")
    integration = registry.get("base_integration", {})
    if integration.get("shared_extension_commit") != EXPECTED_BASE_COMMIT:
        errors.append("Registry shared extension commit mismatch")
    if integration.get("shared_skill_routes", {}).get("legacy_retention_and_archives") != "governing-legacy-retention-and-archives":
        errors.append("Registry shared archive route missing")
    if (root / "skills/governing-legacy-retention-and-archives/SKILL.md").exists():
        errors.append("Base shared Skill body must not be copied locally")

    paths = adapter.get("paths", {})
    for key in ("project_agents", "documentation_map", "active_context", "skill_registry", "archive_root", "archive_readme", "archive_manifest"):
        value = paths.get(key)
        if not isinstance(value, str) or not _safe(value):
            errors.append(f"unsafe or missing adapter path: {key}")
        elif not (root / value).exists():
            errors.append(f"required path missing: {value}")
    for key in ("canonical_sources", "protected_paths", "legacy_search_roots", "generated_derivative_roots", "protected_evidence_roots"):
        values = paths.get(key)
        if not isinstance(values, list) or any(not isinstance(item, str) or not _safe(item) for item in values):
            errors.append(f"unsafe or missing adapter path list: {key}")

    archive_root = (root / paths.get("archive_root", "docs/archive")).resolve()
    for source in paths.get("canonical_sources", []):
        try:
            (root / source).resolve().relative_to(archive_root)
        except ValueError:
            pass
        else:
            errors.append(f"canonical source is inside archive: {source}")

    records = manifest.get("records")
    if manifest.get("manifest_role") != "project-archive-retention-index" or not isinstance(records, list):
        errors.append("invalid archive manifest")
        records = []
    seen_ids: set[str] = set()
    seen_paths: set[str] = set()
    for record in records:
        if not isinstance(record, dict):
            errors.append("archive record must be object")
            continue
        archive_id = record.get("archive_id")
        current_path = record.get("current_path")
        if not isinstance(archive_id, str) or not archive_id or archive_id in seen_ids:
            errors.append(f"invalid or duplicate archive_id: {archive_id}")
        else:
            seen_ids.add(archive_id)
        if not isinstance(current_path, str) or not _safe(current_path) or current_path in seen_paths:
            errors.append(f"unsafe or duplicate current_path: {current_path}")
            continue
        seen_paths.add(current_path)
        path = root / current_path
        if not path.is_file():
            errors.append(f"archive file missing: {current_path}")
        else:
            if path.suffix.lower() == ".md" and not _body(path.read_text(encoding="utf-8", errors="replace")):
                errors.append(f"archived Markdown body is empty: {current_path}")
            if record.get("content_sha256") != hashlib.sha256(path.read_bytes()).hexdigest():
                errors.append(f"archive hash mismatch: {current_path}")
        if record.get("classification") not in CLASSIFICATIONS:
            errors.append(f"invalid classification: {current_path}")
        if record.get("active_authority") is not False or record.get("implementation_authority") != "NONE":
            errors.append(f"archive retains authority: {current_path}")
        if record.get("validation_status") not in STATUSES or not record.get("rollback_ref"):
            errors.append(f"archive validation or rollback missing: {current_path}")
        for replacement in record.get("superseded_by", []):
            if isinstance(replacement, str) and replacement.startswith("external:"):
                continue
            if not isinstance(replacement, str) or not _safe(replacement) or not (root / replacement).exists():
                errors.append(f"replacement missing: {current_path} -> {replacement}")

    if archive_root.is_dir():
        for path in archive_root.rglob("*"):
            if path.is_file() and path.suffix.lower() in {".md", ".json", ".txt", ".yml", ".yaml"}:
                text = path.read_text(encoding="utf-8", errors="replace")
                if any(pattern.search(text) for pattern in SECRET_PATTERNS):
                    errors.append(f"secret-like material in archive: {path.relative_to(root)}")
    readme = root / paths.get("archive_readme", "docs/archive/README.md")
    if readme.is_file():
        text = readme.read_text(encoding="utf-8")
        for token in ("현재 정본이 아니며 구현 권한이 없다", "원문을 비우지 않는다", "비밀키"):
            if token not in text:
                errors.append(f"archive README missing token: {token}")
    return sorted(set(errors))


def main() -> int:
    errors = validate()
    if errors:
        print("Ten Paces archive governance validation FAILED")
        for error in errors:
            print(f"- {error}")
        return 1
    print("Ten Paces archive governance validation PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
