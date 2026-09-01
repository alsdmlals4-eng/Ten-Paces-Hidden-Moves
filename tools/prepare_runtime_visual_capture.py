from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from register_runtime_visual_capture import (
    CaptureValidationError,
    prepare_freshness_receipt,
)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Prepare a one-run freshness receipt while the expected runtime "
            "capture path is absent."
        )
    )
    parser.add_argument("--project-root", required=True, type=Path)
    parser.add_argument("--source-image", required=True, type=Path)
    parser.add_argument("--freshness-receipt", required=True, type=Path)
    parser.add_argument("--capture-run-id", required=True)
    parser.add_argument("--source-commit", required=True)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        receipt = prepare_freshness_receipt(
            project_root=args.project_root,
            source_image=args.source_image,
            receipt_path=args.freshness_receipt,
            capture_run_id=args.capture_run_id,
            source_commit=args.source_commit,
        )
    except CaptureValidationError as exc:
        print(f"runtime visual capture preparation rejected: {exc}", file=sys.stderr)
        return 2
    print(
        json.dumps(
            {
                "capture_run_id": receipt["capture_run_id"],
                "source_image": receipt["source_image"],
                "freshness_receipt": str(args.freshness_receipt.resolve()),
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
