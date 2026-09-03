#!/usr/bin/env python3
"""Publish the additive Human Game Blueprint without replacing its 36-page base.

The old Master Production GDD is retained as intact PDF pages.  The focused
front-duel visual material is rebuilt into a temporary PDF and interleaved
beside the master sections it explains.  This is deliberately an additive
publication: no baseline page is summarized, rasterized, or discarded.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path
from tempfile import NamedTemporaryFile, TemporaryDirectory

from pypdf import PdfReader, PdfWriter
from reportlab.lib.colors import HexColor
from reportlab.lib.pagesizes import A4, landscape
from reportlab.pdfgen.canvas import Canvas

import build_frontal_duel_visual_blueprint_pdf as frontal


ROOT = Path(__file__).resolve().parents[1]
BASELINE_PDF = ROOT / "exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf"
DEFAULT_OUTPUT = ROOT / "exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf"
PAGE_W, PAGE_H = landscape(A4)
EXPECTED_BASELINE_PAGES = 36
EXPECTED_ADDITIVE_PAGES = 16
EXPECTED_MASTER_PAGES = 52


def _draw_cover(output: Path) -> None:
    """Draw the one current cover that names the preservation contract."""
    normal, bold = frontal.register_fonts()
    with NamedTemporaryFile(prefix="ten-paces-human-blueprint-cover-", suffix=".pdf", dir=output.parent, delete=False) as temp:
        temp_path = Path(temp.name)
    try:
        canvas = Canvas(str(temp_path), pagesize=landscape(A4), pageCompression=1)
        frontal.draw_image(canvas, frontal.ASSETS["runtime_plan"], 0, 0, PAGE_W, PAGE_H)
        frontal.rect(canvas, 34, 47, PAGE_W - 68, 216, frontal.INK, stroke=frontal.GOLD, alpha=0.94)
        frontal.label(canvas, "HUMAN GAME BLUEPRINT · ADDITIVE EDITION", PAGE_W / 2, 229, 11, bold, frontal.PAPER, centered=True)
        frontal.label(canvas, "십보강호", PAGE_W / 2, 181, 34, bold, frontal.PAPER, centered=True)
        frontal.label(canvas, "공개 단서 · 숨은 계획 · 실행과 복기", PAGE_W / 2, 148, 15, normal, frontal.GOLD, centered=True)
        frontal.label(canvas, "36쪽 Master GDD를 보존하고, 목표·시스템·FM·와이어프레임·이미지 제작 보드를 추가한 52쪽 사람용 파생본", PAGE_W / 2, 118, 9.6, normal, HexColor("#d7c59d"), centered=True)
        frontal.label(canvas, "2026-09-03 · current task PR #321 · 문서 이미지는 런타임·사람 플레이 증거를 대체하지 않음", PAGE_W / 2, 92, 8.5, normal, HexColor("#c7b58d"), centered=True)
        frontal.rect(canvas, 34, 18, PAGE_W - 68, 19, frontal.PANEL, alpha=0.92)
        frontal.label(canvas, "보존 규칙: 36쪽 기준 문서는 페이지 원문 그대로 남기며, 새 15쪽은 관련 장의 시각·구조·생산 보조 레이어로만 삽입한다.", PAGE_W / 2, 24, 7.8, normal, frontal.PAPER, centered=True)
        canvas.setTitle("십보강호 Human Game Blueprint · Additive Edition")
        canvas.setAuthor("Ten Paces Hidden Moves")
        canvas.setSubject("52-page derived human view: preserved Master GDD plus current frontal-duel planning, visual, and production layers")
        canvas.save()
        os.replace(temp_path, output)
    finally:
        if temp_path.exists():
            temp_path.unlink()


def _append_range(writer: PdfWriter, reader: PdfReader, start: int, stop: int) -> None:
    for page_index in range(start, stop):
        writer.add_page(reader.pages[page_index])


def _append_interleaved_pages(writer: PdfWriter, baseline: PdfReader, addendum: PdfReader) -> None:
    """Keep all baseline pages ordered while placing each visual page by topic."""
    # The addendum cover is intentionally replaced by this publication's cover.
    _append_range(writer, baseline, 0, 8)  # baseline 01-08
    writer.add_page(addendum.pages[1])  # visual direction
    writer.add_page(addendum.pages[2])  # project goals and system map
    _append_range(writer, baseline, 8, 9)  # baseline 09 / flow
    _append_range(writer, addendum, 3, 7)  # capture, Flow Map, plan and prep wireframes
    _append_range(writer, baseline, 9, 12)  # baseline 10-12
    writer.add_page(addendum.pages[7])  # cards
    _append_range(writer, baseline, 12, 14)  # baseline 13-14
    _append_range(writer, addendum, 8, 11)  # combat/reveal wireframes and reveal contract
    _append_range(writer, baseline, 14, 23)  # baseline 15-23
    _append_range(writer, addendum, 11, 15)  # image pipeline, asset board, cases, evidence
    _append_range(writer, baseline, 23, 36)  # baseline 24-36
    writer.add_page(addendum.pages[15])  # handoff


def _write_atomically(writer: PdfWriter, output: Path) -> None:
    with NamedTemporaryFile(prefix="ten-paces-human-blueprint-", suffix=".pdf", dir=output.parent, delete=False) as temp:
        temp_path = Path(temp.name)
    try:
        with temp_path.open("wb") as stream:
            writer.write(stream)
        os.replace(temp_path, output)
    finally:
        if temp_path.exists():
            temp_path.unlink()


def build(output: Path) -> None:
    frontal.must_exist()
    if not BASELINE_PDF.is_file():
        raise FileNotFoundError(f"Missing preserved 36-page baseline: {BASELINE_PDF}")

    output.parent.mkdir(parents=True, exist_ok=True)
    with TemporaryDirectory(prefix="ten-paces-human-blueprint-") as directory:
        temporary_root = Path(directory)
        cover_path = temporary_root / "cover.pdf"
        addendum_path = temporary_root / "frontal-duel-addendum.pdf"
        _draw_cover(cover_path)
        frontal.build(addendum_path)

        baseline = PdfReader(str(BASELINE_PDF))
        addendum = PdfReader(str(addendum_path))
        cover = PdfReader(str(cover_path))
        if len(baseline.pages) != EXPECTED_BASELINE_PAGES:
            raise ValueError(f"Expected {EXPECTED_BASELINE_PAGES} preserved baseline pages, found {len(baseline.pages)}")
        if len(addendum.pages) != EXPECTED_ADDITIVE_PAGES:
            raise ValueError(f"Expected {EXPECTED_ADDITIVE_PAGES} focused pages, found {len(addendum.pages)}")

        writer = PdfWriter()
        writer.add_page(cover.pages[0])
        _append_interleaved_pages(writer, baseline, addendum)
        if len(writer.pages) != EXPECTED_MASTER_PAGES:
            raise AssertionError(f"Expected {EXPECTED_MASTER_PAGES} master pages, assembled {len(writer.pages)}")
        writer.add_metadata(
            {
                "/Title": "십보강호 Human Game Blueprint · Additive Edition",
                "/Author": "Ten Paces Hidden Moves",
                "/Subject": "Preserved 36-page Master GDD with current frontal-duel planning, visual, wireframe, and production additions",
            }
        )
        _write_atomically(writer, output)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    output = args.output.resolve()
    build(output)
    print(f"PDF_PUBLISHED {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
