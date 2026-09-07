#!/usr/bin/env python3
"""Publish the image-centred human PDF for the frontal-duel blueprint.

The Markdown blueprint remains the canonical rule and interaction source.  This
script deliberately uses approved project imagery and machine runtime captures
for the derived PDF so a generic diagram never replaces the visual contract.
"""

from __future__ import annotations

import argparse
import os
from io import BytesIO
from pathlib import Path
from tempfile import NamedTemporaryFile

from PIL import Image
from reportlab.lib.colors import Color, HexColor
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas


ROOT = Path(__file__).resolve().parents[1]
PAGE_W, PAGE_H = landscape(A4)
PAGE_COUNT = 16

ASSETS = {
    "runtime_plan": ROOT / "docs/evidence/runtime-captures/TEN-RVC-20260903-003.png",
    "runtime_hover": ROOT / "docs/evidence/runtime-captures/TEN-RVC-20260903-004.png",
    "runtime_locked": ROOT / "docs/evidence/runtime-captures/TEN-RVC-20260903-005.png",
    "runtime_reveal": ROOT / "docs/evidence/runtime-captures/TEN-RVC-20260903-006.png",
    "visual_board": ROOT / "docs/visual-assets/planning/PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2.png",
    "whole_scene_candidate": ROOT / "docs/visual-assets/candidates/FRONTAL_COURTYARD_DUEL_SEQUENCE_BOARD_20260902_v2.png",
    "reveal_sequence_candidate": ROOT / "docs/visual-assets/candidates/FRONTAL_DUEL_REVEAL_SEQUENCE_VISUAL_BOARD_20260902_v1.png",
    "background": ROOT / "docs/visual-assets/approved/FRONTAL_COURTYARD_DUEL_BACKGROUND_02_v1.png",
    "banner": ROOT / "docs/visual-assets/approved/FRONTAL_COURTYARD_BANNER_OVERLAY_01_v1.png",
    "player": ROOT / "docs/visual-assets/approved/WANDERER_COMBAT_BATTLER_02_20260902_v2.png",
    "opponent": ROOT / "docs/visual-assets/approved/MASKED_SWORDSMAN_COMBAT_BATTLER_02_20260902_v2.png",
    "card_atlas": ROOT / "assets/ui/cards/martial_ultimate_card_illustration_atlas_01_v1.png",
}

PAPER = HexColor("#e6d7b6")
INK = HexColor("#17130f")
GOLD = HexColor("#bd8c37")
MUTED = HexColor("#6f6049")
PANEL = HexColor("#211911")
LINE = HexColor("#715a35")
PDF_RASTER_DPI = 144
JPEG_QUALITY = 82


def register_fonts() -> tuple[str, str]:
    normal = Path(r"C:\Windows\Fonts\malgun.ttf")
    bold = Path(r"C:\Windows\Fonts\malgunbd.ttf")
    if not normal.exists() or not bold.exists():
        raise RuntimeError("Korean PDF fonts are unavailable: expected Malgun Gothic in C:\\Windows\\Fonts")
    pdfmetrics.registerFont(TTFont("TenPaces", str(normal)))
    pdfmetrics.registerFont(TTFont("TenPacesBold", str(bold)))
    return "TenPaces", "TenPacesBold"


def must_exist() -> None:
    missing = [str(path.relative_to(ROOT)) for path in ASSETS.values() if not path.exists()]
    if missing:
        raise FileNotFoundError("Missing required visual inputs: " + ", ".join(missing))


def fit_crop(image: Image.Image, width: float, height: float) -> Image.Image:
    """Crop in memory; preserve visual source bytes and avoid temporary image files."""
    target = width / height
    source = image.width / image.height
    if source > target:
        crop_width = int(image.height * target)
        left = (image.width - crop_width) // 2
        return image.crop((left, 0, left + crop_width, image.height))
    crop_height = int(image.width / target)
    top = (image.height - crop_height) // 2
    return image.crop((0, top, image.width, top + crop_height))


def contain_dimensions(source_width: int, source_height: int, box_width: float, box_height: float) -> tuple[int, int]:
    """Return whole-image dimensions that fit inside a target box without crop."""
    if source_width <= 0 or source_height <= 0 or box_width <= 0 or box_height <= 0:
        raise ValueError("source and target dimensions must be positive")
    scale = min(box_width / source_width, box_height / source_height)
    return max(1, round(source_width * scale)), max(1, round(source_height * scale))


def _display_pixels(width: float, height: float) -> tuple[int, int]:
    """Match embedded imagery to the proof-render DPI instead of source-pixel size."""
    return max(1, round(width * PDF_RASTER_DPI / 72)), max(1, round(height * PDF_RASTER_DPI / 72))


def _resized_for_pdf(image: Image.Image, width: float, height: float) -> Image.Image:
    target_width, target_height = _display_pixels(width, height)
    if image.width == target_width and image.height == target_height:
        return image
    return image.resize((target_width, target_height), Image.Resampling.LANCZOS)


def _pdf_image_reader(image: Image.Image) -> ImageReader:
    """JPEG-compress opaque proof images while preserving transparent source modules."""
    alpha = image.getchannel("A") if image.mode == "RGBA" else None
    if alpha is not None and alpha.getextrema()[0] < 255:
        return ImageReader(image)
    encoded = BytesIO()
    image.convert("RGB").save(encoded, format="JPEG", quality=JPEG_QUALITY, optimize=True, progressive=True)
    encoded.seek(0)
    return ImageReader(encoded)


def draw_image(c: Canvas, source: Path, x: float, y: float, width: float, height: float, *, alpha: float = 1.0) -> None:
    with Image.open(source) as opened:
        crop = fit_crop(opened.convert("RGBA"), width, height)
        reader = _pdf_image_reader(_resized_for_pdf(crop, width, height))
        c.saveState()
        if alpha < 1:
            c.setFillAlpha(alpha)
        c.drawImage(reader, x, y, width=width, height=height, mask="auto")
        c.restoreState()


def draw_image_contain(c: Canvas, source: Path, x: float, y: float, width: float, height: float, *, alpha: float = 1.0) -> None:
    """Centre the full image inside a box; needed for independent tall alpha modules."""
    with Image.open(source) as opened:
        image = opened.convert("RGBA")
        target_width, target_height = contain_dimensions(image.width, image.height, width, height)
        reader = _pdf_image_reader(_resized_for_pdf(image, target_width, target_height))
        c.saveState()
        if alpha < 1:
            c.setFillAlpha(alpha)
        c.drawImage(
            reader,
            x + (width - target_width) / 2,
            y + (height - target_height) / 2,
            width=target_width,
            height=target_height,
            mask="auto",
        )
        c.restoreState()


def rect(c: Canvas, x: float, y: float, width: float, height: float, fill: Color, *, stroke: Color | None = None, alpha: float = 1.0) -> None:
    c.saveState()
    if alpha < 1:
        c.setFillAlpha(alpha)
    c.setFillColor(fill)
    if stroke is not None:
        c.setStrokeColor(stroke)
        c.setLineWidth(1)
        c.rect(x, y, width, height, fill=1, stroke=1)
    else:
        c.rect(x, y, width, height, fill=1, stroke=0)
    c.restoreState()


def label(c: Canvas, text: str, x: float, y: float, size: float, font: str, color: Color = INK, *, centered: bool = False) -> None:
    c.setFont(font, size)
    c.setFillColor(color)
    if centered:
        c.drawCentredString(x, y, text)
    else:
        c.drawString(x, y, text)


def wrap_lines(text: str, max_chars: int) -> list[str]:
    result: list[str] = []
    for paragraph in text.split("\n"):
        while len(paragraph) > max_chars:
            split = paragraph.rfind(" ", 0, max_chars + 1)
            if split < max_chars // 2:
                split = max_chars
            result.append(paragraph[:split].strip())
            paragraph = paragraph[split:].strip()
        if paragraph:
            result.append(paragraph)
    return result


def paragraph(c: Canvas, text: str, x: float, top: float, width: float, *, size: float, leading: float, font: str, color: Color = INK) -> float:
    max_chars = max(8, int(width / (size * 0.86)))
    c.setFillColor(color)
    c.setFont(font, size)
    current = top
    for line in wrap_lines(text, max_chars):
        c.drawString(x, current, line)
        current -= leading
    return current


def page_shell(c: Canvas, number: int, title: str, subtitle: str, normal: str, bold: str) -> None:
    rect(c, 0, 0, PAGE_W, PAGE_H, PAPER)
    rect(c, 0, PAGE_H - 54, PAGE_W, 54, INK)
    label(c, "십보강호 · 숨은 수의 비무", 26, PAGE_H - 22, 11, bold, PAPER)
    label(c, title, PAGE_W / 2, PAGE_H - 27, 18, bold, PAPER, centered=True)
    label(c, subtitle, PAGE_W / 2, PAGE_H - 43, 8.5, normal, HexColor("#c7b58d"), centered=True)
    c.setStrokeColor(LINE)
    c.line(26, 31, PAGE_W - 26, 31)
    label(c, "정면 결투 행동 흐름 · 이미지 중심 파생 블루프린트", 26, 16, 8, normal, MUTED)
    label(c, f"{number} / {PAGE_COUNT}", PAGE_W - 26, 16, 8, normal, MUTED, centered=True)


def callout(c: Canvas, number: str, heading: str, body: str, x: float, y: float, width: float, height: float, normal: str, bold: str) -> None:
    rect(c, x, y, width, height, HexColor("#f1e5c9"), stroke=LINE)
    rect(c, x + 8, y + height - 30, 23, 20, GOLD)
    label(c, number, x + 19.5, y + height - 24, 10, bold, INK, centered=True)
    label(c, heading, x + 39, y + height - 23, 10, bold)
    paragraph(c, body, x + 12, y + height - 45, width - 24, size=8, leading=11, font=normal, color=MUTED)


def flow_node(c: Canvas, heading: str, subline: str, x: float, y: float, width: float, *, highlighted: bool, normal: str, bold: str) -> None:
    fill = HexColor("#e5cea0") if highlighted else HexColor("#f1e5c9")
    rect(c, x, y, width, 78, fill, stroke=LINE)
    label(c, heading, x + width / 2, y + 47, 11, bold, INK, centered=True)
    label(c, subline, x + width / 2, y + 24, 7.8, normal, MUTED, centered=True)


def wire_label(c: Canvas, text: str, x: float, y: float, width: float, *, active: bool, normal: str, bold: str) -> None:
    fill = GOLD if active else HexColor("#f1e5c9")
    text_color = INK if active else MUTED
    rect(c, x, y, width, 27, fill, stroke=LINE)
    label(c, text, x + width / 2, y + 9, 8.4, bold if active else normal, text_color, centered=True)


def page_cover(c: Canvas, normal: str, bold: str) -> None:
    draw_image(c, ASSETS["runtime_plan"], 0, 0, PAGE_W, PAGE_H)
    rect(c, 34, 61, PAGE_W - 68, 172, INK, stroke=GOLD, alpha=0.91)
    label(c, "실제 화면을 기준으로 다시 엮은", PAGE_W / 2, 198, 12, normal, PAPER, centered=True)
    label(c, "정면 결투 행동 흐름", PAGE_W / 2, 159, 31, bold, PAPER, centered=True)
    label(c, "이미지 중심 블루프린트", PAGE_W / 2, 125, 22, bold, GOLD, centered=True)
    label(c, "계획 · 잠금 · 한 수 공개 · 합 · 정착", PAGE_W / 2, 91, 12, normal, HexColor("#d7c59d"), centered=True)
    rect(c, 34, 31, PAGE_W - 68, 22, PANEL, alpha=0.88)
    label(c, "표지와 본문 모두 실제 Godot 캡처·승인 시각 보드·카드/VFX atlas를 사용합니다.", PAGE_W / 2, 38, 8.5, normal, PAPER, centered=True)


def page_visual_direction(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 2, "승인된 시각 문법", "정면 석정·공유 바닥·먹선 카드·짧은 합의 인상", normal, bold)
    draw_image(c, ASSETS["visual_board"], 25, 90, PAGE_W - 50, 420)
    rect(c, 25, 90, PAGE_W - 50, 420, Color(0, 0, 0, alpha=0), stroke=LINE)
    captions = [
        ("01", "석정", "같은 바닥에 선 정면 대치"),
        ("02", "계획", "수는 카드로 잠그고 준비한다"),
        ("03", "공개", "한 수의 양측 행동만 마주 보인다"),
        ("04", "합", "결정 순간만 먹선·금색을 쓴다"),
    ]
    cell_w = (PAGE_W - 50) / 4
    for index, (number, heading, body) in enumerate(captions):
        x = 25 + index * cell_w
        rect(c, x, 48, cell_w - 2, 30, PANEL, alpha=0.95)
        label(c, number, x + 10, 63, 8, bold, GOLD)
        label(c, heading, x + 31, 63, 9, bold, PAPER)
        label(c, body, x + 10, 52, 7.5, normal, HexColor("#d3c29d"))


def page_goal_system_map(c: Canvas, normal: str, bold: str) -> None:
    """Expose project purpose, current condition, request reason, and effect."""
    page_shell(c, 3, "프로젝트 목표 · 시스템 지도", "무엇을 만들고 있는지와 무엇이 아직 증명되지 않았는지", normal, bold)
    draw_image(c, ASSETS["runtime_plan"], 24, 288, 310, 225)
    rect(c, 24, 288, 310, 225, Color(0, 0, 0, alpha=0), stroke=LINE)
    rect(c, 351, 288, 465, 225, PANEL, stroke=GOLD)
    label(c, "핵심 목표", 373, 479, 15, bold, PAPER)
    paragraph(
        c,
        "공개 거리와 해결 이력만으로 서로의 숨은 수를 읽는 1대1 비무. "
        "플레이어는 매 라운드 3수 → 해결 → 3수 → 해결 → 4수를 배치하고, "
        "상대는 미확정 계획을 읽지 않는다.",
        373,
        452,
        415,
        size=10,
        leading=15,
        font=normal,
        color=PAPER,
    )
    label(c, "현재 상태 → 요청 이유 → 기대 효과", 373, 355, 9, bold, GOLD)
    paragraph(
        c,
        "현재: 준비 surface와 잠금/현재 공개 캡처가 존재한다.  "
        "이유: 문서가 짧은 화면 시안으로 축소되면 기획·시스템·증거의 연결이 사라진다.  "
        "효과: 같은 Blueprint에서 목표·UI·연출·검증의 다음 안전 작업을 바로 비교한다.",
        373,
        336,
        415,
        size=8.6,
        leading=13,
        font=normal,
        color=HexColor("#d3c29d"),
    )
    systems = [
        ("계획", "3/3/4 행동 묶음 · 카드 배치", "IMPLEMENTED / CAPTURED"),
        ("정보", "거리·관찰·공개 경계", "PARTIAL / CURRENT UI"),
        ("해결", "현재 행동 공개 → 합 → 정착", "PARTIAL / MOTION QUALITY PENDING"),
        ("시각", "분리 모듈 → Godot 합성", "LOCKED / MACHINE CAPTURED"),
    ]
    y = 242
    for heading, body, state in systems:
        rect(c, 24, y, 792, 37, HexColor("#f1e5c9"), stroke=LINE)
        label(c, heading, 38, y + 20, 10, bold, INK)
        label(c, body, 125, y + 20, 8.8, normal, MUTED)
        label(c, state, 751, y + 20, 6.1, bold, GOLD, centered=True)
        y -= 44
    rect(c, 24, 61, 792, 31, HexColor("#211911"), stroke=LINE)
    label(c, "판정 규칙: 구현·기계 캡처·사람 UX·실기기·출시 증거는 서로 대체하지 않는다.", PAGE_W / 2, 72, 8.8, bold, PAPER, centered=True)


def page_plan_capture(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 4, "계획 편집 · 실제 Godot 화면", "기계 런타임 캡처 TEN-RVC-20260903-003", normal, bold)
    draw_image(c, ASSETS["runtime_plan"], 24, 120, 528, 330)
    rect(c, 24, 120, 528, 330, Color(0, 0, 0, alpha=0), stroke=LINE)
    # Highlight only features that are present in the capture.
    c.saveState()
    c.setStrokeColor(GOLD)
    c.setLineWidth(2)
    c.rect(26, 305, 524, 73, fill=0, stroke=1)  # logical timeline / plan slots
    c.rect(26, 121, 524, 134, fill=0, stroke=1)  # unified action-card grid
    c.restoreState()
    callout(c, "1", "거리와 공유 바닥", "두 인물은 중앙 거리 표식으로 읽고, 논리 10칸이나 바닥 번호는 전면에 노출하지 않는다.", 576, 382, 240, 68, normal, bold)
    callout(c, "2", "3/3/4 계획", "현재 3수 묶음과 잠긴 후속 묶음이 한 줄로 보인다. 슬롯 수는 행동 수를 뜻한다.", 576, 303, 240, 68, normal, bold)
    callout(c, "3", "통합 카드 격자", "기초·무공·절초 탭은 하나의 카드 shell을 공유한다. 삽화, 수, 비용, 효과는 카드에서 보인다.", 576, 224, 240, 68, normal, bold)
    callout(c, "4", "방향 입력의 경계", "이동만 전진/후퇴를 고른다. 공격·무공·절초는 유효한 대상에 자동으로 적용한다.", 576, 145, 240, 68, normal, bold)
    rect(c, 24, 69, 792, 31, HexColor("#f1e5c9"), stroke=LINE)
    label(c, "캡처가 보여주는 것: 계획 편집·카드 사실·현재 수. 잠금/한 수 공개는 별도 캡처와 다음 Flow Map에서 단계별로 구분한다.", PAGE_W / 2, 80, 8.2, normal, MUTED, centered=True)


def page_flow_map(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 5, "단계별 FM · Flow Map", "입력·잠금·현재 행동 공개·합·정착의 책임 경계", normal, bold)
    draw_image(c, ASSETS["runtime_plan"], 25, 404, 300, 116)
    rect(c, 25, 404, 300, 116, Color(0, 0, 0, alpha=0), stroke=LINE)
    draw_image(c, ASSETS["visual_board"], 339, 404, 477, 116)
    rect(c, 339, 404, 477, 116, Color(0, 0, 0, alpha=0), stroke=LINE)
    label(c, "실제 Godot 계획 편집", 34, 386, 8, bold, MUTED)
    label(c, "승인된 공개·합 시각 방향", 350, 386, 8, bold, MUTED)
    nodes = [
        ("계획 편집", "카드·관찰·현재 슬롯", False),
        ("행동계획 잠금", "첫 CTA · resolver 0회", True),
        ("N수 실행", "둘째 CTA · 1회 시작", True),
        ("현재 수 공개", "양측 카드·이유", False),
        ("합·정착", "VFX·거리/자원 갱신", True),
        ("복기", "원인 → 적용 → 결과", False),
    ]
    node_w, start_x = 119, 26
    for index, (heading, subline, highlighted) in enumerate(nodes):
        x = start_x + index * 132
        flow_node(c, heading, subline, x, 286, node_w, highlighted=highlighted, normal=normal, bold=bold)
        if index < len(nodes) - 1:
            label(c, "→", x + 125, 312, 21, bold, GOLD, centered=True)
    rect(c, 25, 215, 792, 43, PANEL)
    label(c, "3수 → 해결 → 3수 → 해결 → 4수  ·  한 묶음을 잠근 뒤 현재 수만 공개하고, 해결 뒤에만 다음 수로 간다.", PAGE_W / 2, 231, 10, bold, PAPER, centered=True)
    callout(c, "입력", "플레이어가 조작하는 것", "기초·무공·절초 카드 선택, 이동만 전진/후퇴 intent, 관찰점 사용, 잠금 뒤 실행 시작.", 25, 76, 378, 118, normal, bold)
    callout(c, "보호", "끝까지 숨길 것", "미래 timing의 상대 행동, 관찰 전 기술명·대상·피해, 플레이어의 미확정 계획을 읽는 AI, 논리 타일/공격 방향 UI.", 438, 76, 378, 118, normal, bold)


def page_plan_wireframe(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 6, "계획 편집 · 구조 와이어프레임", "p4 실제 Godot 화면을 대체하지 않는 layout/content contract", normal, bold)
    rect(c, 24, 94, 505, 422, PANEL, stroke=GOLD)
    rect(c, 41, 469, 471, 30, HexColor("#17130f"), stroke=LINE)
    label(c, "나: 체력·기력·내력·기세", 52, 480, 8.5, bold, PAPER)
    label(c, "제 N 라운드 · 현재 3수", 278, 480, 8.8, bold, PAPER, centered=True)
    label(c, "상대: 체력·기력·내력·기세", 447, 480, 7.4, bold, PAPER, centered=True)
    rect(c, 41, 339, 471, 111, HexColor("#4c4030"), stroke=LINE)
    label(c, "공유 석정 바닥 · 동일 foot-anchor · 논리 grid/number 미표시", 276, 350, 8, normal, HexColor("#d3c29d"), centered=True)
    label(c, "나", 117, 395, 21, bold, PAPER, centered=True)
    label(c, "거리 2", 276, 394, 16, bold, PAPER, centered=True)
    label(c, "상대", 435, 395, 21, bold, PAPER, centered=True)
    rect(c, 41, 284, 471, 39, HexColor("#e5cea0"), stroke=LINE)
    label(c, "현재 계획 3수", 55, 299, 9, bold)
    wire_label(c, "1 · 이동 / 전진", 145, 290, 100, active=False, normal=normal, bold=bold)
    wire_label(c, "2 · 전조", 253, 290, 78, active=False, normal=normal, bold=bold)
    wire_label(c, "3 · 공격", 339, 290, 72, active=False, normal=normal, bold=bold)
    wire_label(c, "행동계획 잠금", 419, 290, 83, active=True, normal=normal, bold=bold)
    rect(c, 41, 122, 471, 145, HexColor("#17130f"), stroke=LINE)
    label(c, "기초    무공    절초", 58, 245, 10, bold, GOLD)
    for index, card_name in enumerate(("이동", "보법", "막기", "회피", "속공")):
        x = 58 + index * 88
        rect(c, x, 144, 77, 78, HexColor("#f1e5c9"), stroke=GOLD)
        label(c, f"{index + 1} · {card_name}", x + 7, 199, 8.5, bold)
        label(c, "N수 · 비용", x + 7, 177, 7.2, normal, MUTED)
        label(c, "사거리/효과", x + 7, 157, 7.2, normal, MUTED)
    callout(c, "A", "상태 HUD", "상태·관찰 기록은 위에 고정한다. 상대의 숨은 기술명·대상·피해는 넣지 않는다.", 553, 410, 263, 93, normal, bold)
    callout(c, "B", "행동계획 행", "현재 묶음만 편집한다. 첫 CTA는 plan_locked 진입이며 resolver를 호출하지 않는다.", 553, 304, 263, 93, normal, bold)
    callout(c, "C", "공통 카드 표면", "기초·무공·절초 탭은 같은 shell을 쓴다. 이름·N수·비용·사거리/효과는 card에서 읽는다.", 553, 198, 263, 93, normal, bold)
    draw_image(c, ASSETS["runtime_plan"], 553, 94, 263, 82)
    rect(c, 553, 94, 263, 82, Color(0, 0, 0, alpha=0), stroke=LINE)
    label(c, "이미지 앵커: p3의 실제 runtime capture", 554, 79, 7.5, normal, MUTED)


def page_preparation_wireframe(c: Canvas, normal: str, bold: str) -> None:
    """Show the 20 / 50 / 30 preparation screen contract separately."""
    page_shell(c, 7, "준비 화면 · 구조 와이어프레임", "상단 20% · 중단 전투 50% · 하단 선택 30%", normal, bold)
    rect(c, 24, 85, 792, 430, PANEL, stroke=GOLD)
    # 20% HUD
    rect(c, 42, 426, 756, 71, HexColor("#17130f"), stroke=LINE)
    rect(c, 52, 436, 208, 50, HexColor("#302519"), stroke=GOLD)
    rect(c, 580, 436, 208, 50, HexColor("#302519"), stroke=GOLD)
    label(c, "나 · 체력/기력/내력 · 기세 0/5 · 상태", 63, 462, 8.3, bold, PAPER)
    label(c, "상대 · 숫자 비공개 · 기세 0/5 · 상태", 590, 462, 8.3, bold, PAPER)
    rect(c, 318, 436, 204, 50, HexColor("#302519"), stroke=GOLD)
    label(c, "제 N 라운드 · 행동 묶음 1/3", PAGE_W / 2, 462, 9.2, bold, PAPER, centered=True)
    # 50% combat stage
    rect(c, 42, 218, 756, 194, HexColor("#4c4030"), stroke=LINE)
    label(c, "중단 · 공유 석정 · foot anchor와 contact shadow", PAGE_W / 2, 389, 8.3, normal, HexColor("#d3c29d"), centered=True)
    label(c, "나", 158, 306, 20, bold, PAPER, centered=True)
    label(c, "거리 2", PAGE_W / 2, 307, 18, bold, PAPER, centered=True)
    label(c, "상대", 683, 306, 20, bold, PAPER, centered=True)
    rect(c, 42, 222, 756, 27, HexColor("#211911"), stroke=LINE)
    label(c, "거리·상태는 읽되, 논리 타일/방향 선택/숨은 미래 수는 화면에 드러내지 않는다.", PAGE_W / 2, 232, 8.0, normal, PAPER, centered=True)
    # 30% selection dock
    rect(c, 42, 102, 756, 96, HexColor("#17130f"), stroke=LINE)
    label(c, "현재 계획 · 3수", 55, 177, 8.6, bold, GOLD)
    for index, text in enumerate(("1수", "2수", "3수")):
        x = 163 + index * 95
        wire_label(c, text, x, 158, 84, active=False, normal=normal, bold=bold)
    wire_label(c, "행동계획 잠금", 457, 158, 112, active=True, normal=normal, bold=bold)
    label(c, "기본 · 무공 · 절초", 56, 135, 8.5, bold, PAPER)
    for index in range(5):
        x = 174 + index * 77
        rect(c, x, 111, 67, 33, HexColor("#f1e5c9"), stroke=LINE)
        label(c, f"카드 {index + 1}", x + 33.5, 123, 7.2, normal, MUTED, centered=True)
    rect(c, 640, 111, 142, 33, HexColor("#302519"), stroke=GOLD)
    label(c, "상대 행동 관찰", 711, 123, 7.5, bold, PAPER, centered=True)
    label(c, "준비 상태: 하단은 행동 배치·카드 hover detail·관찰에만 사용한다.", PAGE_W / 2, 67, 8.0, normal, MUTED, centered=True)


def page_card_art(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 8, "통합 카드 · 삽화와 사실 정보", "카드 그림은 장식이 아니라 행동 출처를 빠르게 읽는 보조 채널", normal, bold)
    draw_image(c, ASSETS["card_atlas"], 24, 180, 493, 286)
    rect(c, 24, 180, 493, 286, Color(0, 0, 0, alpha=0), stroke=LINE)
    draw_image(c, ASSETS["runtime_hover"], 24, 60, 493, 100)
    rect(c, 24, 60, 493, 100, Color(0, 0, 0, alpha=0), stroke=LINE)
    label(c, "실제 카드 rack · 선택된 속공은 사거리 1·기력 1·내력 0·효과를 같은 면에서 읽는다.", 27, 48, 7.5, normal, MUTED)
    callout(c, "A", "항상 보임", "삽화 · 이름 · N수 · 출처 · 유형 · 기력/내력/기세 · 짧은 효과", 545, 391, 270, 75, normal, bold)
    callout(c, "B", "조건부 보임", "공격일 때 사거리, 절초일 때 예약/잠금 사유. 이동/자신 행동에는 가짜 사거리를 쓰지 않는다.", 545, 303, 270, 75, normal, bold)
    callout(c, "C", "상세 패널로 이동", "장문 조건·다단계 효과·풍미 텍스트만 상세로 보낸다. 비용이나 한 줄 효과는 숨기지 않는다.", 545, 215, 270, 75, normal, bold)
    callout(c, "D", "상태도 같은 언어", "선택·focus·disabled·locked·reserved를 색만이 아니라 테두리·문구·상세 설명으로 함께 전달한다.", 545, 127, 270, 75, normal, bold)


def page_combat_wireframe(c: Canvas, normal: str, bold: str) -> None:
    """Lock-state layout contract: only the top HUD and battle remain."""
    page_shell(c, 9, "전투 화면 · 구조 와이어프레임", "행동계획 잠금 뒤 하단 카드 surface는 사라지고 전투가 확장된다", normal, bold)
    rect(c, 24, 84, 792, 432, PANEL, stroke=GOLD)
    rect(c, 43, 443, 754, 54, HexColor("#17130f"), stroke=LINE)
    rect(c, 55, 452, 196, 36, HexColor("#302519"), stroke=GOLD)
    rect(c, 592, 452, 196, 36, HexColor("#302519"), stroke=GOLD)
    label(c, "나 · 체력/기력/내력 · 기세 · 상태", 63, 466, 8.0, bold, PAPER)
    label(c, "상대 · 공개 상태만", 602, 466, 8.0, bold, PAPER)
    label(c, "제 N 라운드 · 현재 행동 N수", PAGE_W / 2, 466, 9.1, bold, PAPER, centered=True)
    rect(c, 43, 126, 754, 301, HexColor("#4c4030"), stroke=LINE)
    label(c, "전투 화면 · 전체 높이의 주 surface", PAGE_W / 2, 401, 9, normal, HexColor("#d3c29d"), centered=True)
    label(c, "나", 154, 261, 25, bold, PAPER, centered=True)
    label(c, "거리 2", PAGE_W / 2, 262, 19, bold, PAPER, centered=True)
    label(c, "상대", 687, 261, 25, bold, PAPER, centered=True)
    rect(c, 269, 169, 304, 52, HexColor("#211911"), stroke=GOLD)
    label(c, "현재 행동 공개 · 다음 수 비공개", PAGE_W / 2, 197, 10.5, bold, PAPER, centered=True)
    label(c, "나의 현재 행동  VS  상대의 현재 행동", PAGE_W / 2, 179, 8.3, normal, GOLD, centered=True)
    rect(c, 43, 97, 754, 19, HexColor("#17130f"), stroke=LINE)
    label(c, "잠금 상태: 하단 카드/계획 surface는 없음 · 상태 HUD와 중앙 결투만 유지", PAGE_W / 2, 103, 7.5, normal, PAPER, centered=True)
    label(c, "표현 순서: 공개 → 판정 → 합/방어/회피 → VFX/피격 → 거리·자원 정착 → 다음 수", PAGE_W / 2, 66, 8.0, bold, MUTED, centered=True)


def page_reveal_wireframe(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 10, "한 수 공개 · 구조 와이어프레임", "현재 timing만 · 원인 판정부터 정착까지의 표현 순서", normal, bold)
    draw_image(c, ASSETS["visual_board"], 25, 362, 792, 158)
    rect(c, 25, 362, 792, 158, Color(0, 0, 0, alpha=0), stroke=LINE)
    rect(c, 25, 186, 792, 154, PANEL, stroke=GOLD)
    label(c, "2번째 행동 공개", PAGE_W / 2, 312, 18, bold, PAPER, centered=True)
    label(c, "현재 수만 공개 · 다음 수는 공개하지 않습니다", PAGE_W / 2, 290, 9, normal, GOLD, centered=True)
    rect(c, 77, 212, 184, 57, HexColor("#f1e5c9"), stroke=GOLD)
    label(c, "나 · 전조 · 1수", 92, 248, 11, bold)
    label(c, "기력 1 · 효과", 92, 226, 8, normal, MUTED)
    label(c, "VS", PAGE_W / 2, 232, 25, bold, GOLD, centered=True)
    rect(c, 581, 212, 184, 57, HexColor("#f1e5c9"), stroke=GOLD)
    label(c, "상대 · 검격 · 1수", 596, 248, 11, bold)
    label(c, "사거리 1 · 효과", 596, 226, 8, normal, MUTED)
    rect(c, 294, 195, 253, 28, HexColor("#e5cea0"), stroke=LINE)
    label(c, "합/방어/회피 · 실제 resolver event", PAGE_W / 2, 205, 8.5, bold, INK, centered=True)
    steps = ("카드 공개", "원인 판정", "합 / 방어 / 회피", "VFX · 피격", "거리 · 자원 정착", "다음 수")
    for index, step in enumerate(steps):
        x = 25 + index * 132
        wire_label(c, step, x, 132, 118, active=index in (0, 3), normal=normal, bold=bold)
        if index < len(steps) - 1:
            label(c, "→", x + 124, 140, 17, bold, GOLD, centered=True)
    rect(c, 25, 70, 792, 39, HexColor("#f1e5c9"), stroke=LINE)
    label(c, "빈 면은 ‘이번 수 행동 없음’으로 명시한다. future action, 기술명·대상·피해의 선공개는 이 구조에 들어오지 않는다.", PAGE_W / 2, 83, 8.5, normal, MUTED, centered=True)


def page_reveal_contract(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 11, "잠금 → 한 수 공개 → 합 → 정착", "계획 이후의 표현 계약 · 실제 캡처와 아직 필요한 evidence를 엄격히 구분", normal, bold)
    # Three image-led stages.
    stages = [
        ("계획 잠금", ASSETS["runtime_locked"], "현재 묶음만 고정하고 하단 선택 surface를 닫는다.", "MACHINE CAPTURE: TEN-RVC-20260903-005"),
        ("한 수 공개", ASSETS["runtime_reveal"], "양측의 현재 행동만 대조하고 미래 수는 숨긴다.", "MACHINE CAPTURE: TEN-RVC-20260903-006"),
        ("합·정착", ASSETS["reveal_sequence_candidate"], "해결 사건 뒤 짧은 충돌과 거리 갱신을 보여준다.", "PENDING: exact motion-quality / settle capture"),
    ]
    stage_w, stage_h, start_x = 240, 240, 25
    for index, (heading, image, body, status) in enumerate(stages):
        x = start_x + index * 278
        draw_image(c, image, x, 220, stage_w, stage_h)
        rect(c, x, 220, stage_w, stage_h, Color(0, 0, 0, alpha=0), stroke=LINE)
        rect(c, x, 180, stage_w, 29, PANEL)
        label(c, f"{index + 1}. {heading}", x + 10, 191, 11, bold, PAPER)
        paragraph(c, body, x + 4, 163, stage_w - 8, size=8.2, leading=11, font=normal, color=INK)
        rect(c, x, 120, stage_w, 29, HexColor("#f1e5c9"), stroke=LINE)
        label(c, status, x + stage_w / 2, 131, 7.2, normal, MUTED, centered=True)
        if index < 2:
            label(c, "→", x + 255, 328, 27, bold, GOLD, centered=True)
    rect(c, 25, 63, PAGE_W - 50, 39, PANEL)
    label(c, "공개 경계: 미래 수·미확정 계획은 절대 보이지 않는다. 관찰은 잠긴 행동 ‘유형’만 기록하고 기술명·대상·피해는 숨긴다.", PAGE_W / 2, 79, 8.8, normal, PAPER, centered=True)


def page_image_production_pipeline(c: Canvas, normal: str, bold: str) -> None:
    """Record the requested whole-scene → modules → runtime composition method."""
    page_shell(c, 12, "이미지 제작 파이프라인", "전체 장면 후보 → 분리 후보 → 합성 · Godot 런타임", normal, bold)
    columns = ((24, 250, "1 · 전체 장면 후보"), (311, 250, "2 · 분리 후보"), (598, 218, "3 · 합성 · Godot 런타임"))
    for x, width, title in columns:
        rect(c, x, 472, width, 27, PANEL, stroke=GOLD)
        label(c, title, x + width / 2, 482, 8.6, bold, PAPER, centered=True)
    draw_image(c, ASSETS["whole_scene_candidate"], 24, 292, 250, 168)
    rect(c, 24, 292, 250, 168, Color(0, 0, 0, alpha=0), stroke=LINE)
    paragraph(c, "역할: 전체 camera·sun·gate·공유 바닥을 먼저 검토. 상태: SUPERSEDED_GENERATED_EXPLORATION — canon/런타임으로 승격하지 않는다.", 29, 274, 240, size=7.7, leading=10, font=normal, color=MUTED)
    module_cards = [
        (ASSETS["background"], "배경", "CANON / IMPLEMENTED"),
        (ASSETS["banner"], "깃발", "CANON / IMPLEMENTED"),
        (ASSETS["player"], "플레이어", "CANON / IMPLEMENTED"),
        (ASSETS["opponent"], "적", "CANON / IMPLEMENTED"),
    ]
    for index, (image, title, state) in enumerate(module_cards):
        x = 311 + (index % 2) * 128
        y = 376 - (index // 2) * 96
        rect(c, x, y, 118, 82, HexColor("#f1e5c9"), stroke=LINE)
        draw_image_contain(c, image, x + 4, y + 23, 110, 54)
        label(c, title, x + 8, y + 11, 7.7, bold, INK)
        label(c, state, x + 59, y + 3, 5.8, normal, GOLD, centered=True)
    paragraph(c, "독립 후보가 같은 그림체·foot-safe margin·소비처 규격을 지킨 뒤에만 합성한다.", 317, 254, 236, size=7.7, leading=10, font=normal, color=MUTED)
    draw_image(c, ASSETS["runtime_plan"], 598, 292, 218, 168)
    rect(c, 598, 292, 218, 168, Color(0, 0, 0, alpha=0), stroke=LINE)
    paragraph(c, "실제 Godot: 배경+깃발+양 전투원+HUD를 합성한 TEN-RVC-20260903-003. 기계 런타임 증거이며 Human/Android/release PASS는 아니다.", 603, 274, 208, size=7.7, leading=10, font=normal, color=MUTED)
    label(c, "전체 장면이 필요하면 먼저 후보로 확인하고, 필요한 요소만 분리 후보로 만든 뒤, 실제 소비처에서 합성·캡처한다.", PAGE_W / 2, 212, 8.7, bold, INK, centered=True)
    rect(c, 24, 74, 792, 112, HexColor("#f1e5c9"), stroke=LINE)
    label(c, "다음 이미지 변경의 고정 게이트", 41, 161, 11, bold, INK)
    paragraph(c, "1) whole-scene candidate로 camera/질량/조명을 검토  →  2) 실제 consumer가 확인된 background·foreground·character·VFX만 분리 후보로 제작  →  3) user final lock 뒤 canon 등록  →  4) Godot 합성/캡처  →  5) 사람 UX·실기기·출시 검증은 별도 기록.", 41, 140, 742, size=8.7, leading=14, font=normal, color=MUTED)


def page_asset_lineage(c: Canvas, normal: str, bold: str) -> None:
    """Make the individual component ownership and reuse boundary inspectable."""
    page_shell(c, 13, "분리 자산 · 합성 보드", "배경·깃발·인물은 별도 파일이며 같은 전투/타이틀 계열에서 재사용", normal, bold)
    draw_image(c, ASSETS["background"], 24, 278, 792, 230)
    rect(c, 24, 278, 792, 230, Color(0, 0, 0, alpha=0), stroke=LINE)
    draw_image(c, ASSETS["banner"], 51, 300, 90, 165)
    draw_image(c, ASSETS["banner"], 699, 300, 90, 165)
    draw_image(c, ASSETS["player"], 152, 294, 140, 174)
    draw_image(c, ASSETS["opponent"], 550, 294, 140, 174)
    label(c, "동일 배경 위에 각각의 alpha battler와 banner를 배치한다. 인물 이미지에 배경·바닥·UI를 굽지 않는다.", PAGE_W / 2, 260, 8.5, normal, MUTED, centered=True)
    rows = [
        ("배경", "FRONTAL_COURTYARD_DUEL_BACKGROUND_02_v1", "BattleBackground / Main Title", "LOCKED · IMPLEMENTED"),
        ("깃발", "FRONTAL_COURTYARD_BANNER_OVERLAY_01_v1", "foreground overlay / Main Title", "LOCKED · IMPLEMENTED"),
        ("플레이어", "WANDERER_COMBAT_BATTLER_02_v2", "CombatCharacter / Main Title", "LOCKED · IMPLEMENTED"),
        ("적", "MASKED_SWORDSMAN_COMBAT_BATTLER_02_v2", "CombatCharacter / Main Title", "LOCKED · IMPLEMENTED"),
    ]
    y = 208
    for role, asset_id, consumer, state in rows:
        rect(c, 24, y, 792, 30, HexColor("#f1e5c9"), stroke=LINE)
        label(c, role, 37, y + 10, 8.5, bold, INK)
        label(c, asset_id, 88, y + 10, 7.4, normal, MUTED)
        label(c, consumer, 425, y + 10, 7.2, normal, MUTED)
        label(c, state, 727, y + 10, 6.5, bold, GOLD, centered=True)
        y -= 34
    rect(c, 24, 54, 792, 31, PANEL, stroke=LINE)
    label(c, "재사용 원칙: 새 화면은 기존 모듈의 verified consumer를 확인한 뒤 소비하며, 장식용 중복 raster를 만들지 않는다.", PAGE_W / 2, 65, 8.4, bold, PAPER, centered=True)


def page_case_status(c: Canvas, normal: str, bold: str) -> None:
    """Expose per-case planning status without conflating validation layers."""
    page_shell(c, 14, "케이스별 현재 상태", "현재 상태 → 요청 이유 → 기대 효과 · 증거 층위를 엄격히 분리", normal, bold)
    headers = (("ID", 28, 54), ("케이스", 88, 140), ("현재 상태", 236, 142), ("요청 이유", 386, 196), ("기대 효과", 589, 205), ("증거", 800, 0))
    rect(c, 24, 476, 792, 28, PANEL, stroke=GOLD)
    for heading, x, _ in headers[:-1]:
        label(c, heading, x, 486, 8, bold, PAPER)
    cases = [
        ("P-01", "준비·카드 배치", "IMPLEMENTED / RVC-003", "하단 선택이 전투와 섞이면 허공에 뜬다", "20/50/30 정보 위계", "MACHINE"),
        ("P-02", "카드 hover 상세", "IMPLEMENTED / RVC-004", "비용·효과가 카드에서 사라지면 판단이 약해진다", "선택 전 사실 확인", "MACHINE"),
        ("P-03", "행동계획 잠금", "IMPLEMENTED / RVC-005", "잠금 뒤 선택 surface가 남으면 실행 상태가 불명확하다", "전투 화면 집중", "MACHINE"),
        ("P-04", "현재 행동 공개", "IMPLEMENTED / RVC-006", "미래 수를 노출하지 않고 서로 겨루어야 한다", "한 수 단위 추론", "MACHINE"),
        ("P-05", "합·모션 품질", "PARTIAL", "공격/방어/회피/피격/절초의 자연스러운 연결 확인 필요", "motion capture / human review", "NOT RUN"),
        ("P-06", "사람·Android·접근성", "NOT_RUN", "자동 캡처가 실제 조작·가독성·실기기를 대체하지 않는다", "별도 UX/device gate", "NOT RUN"),
    ]
    y = 420
    for case_id, name, current, reason, effect, evidence in cases:
        rect(c, 24, y, 792, 48, HexColor("#f1e5c9"), stroke=LINE)
        label(c, case_id, 32, y + 29, 7.8, bold, INK)
        paragraph(c, name, 88, y + 32, 134, size=7.3, leading=9, font=bold, color=INK)
        paragraph(c, current, 236, y + 32, 136, size=6.9, leading=8.5, font=normal, color=MUTED)
        paragraph(c, reason, 386, y + 34, 185, size=6.8, leading=8.5, font=normal, color=MUTED)
        paragraph(c, effect, 589, y + 34, 190, size=6.8, leading=8.5, font=normal, color=MUTED)
        label(c, evidence, 789, y + 29, 6.2, bold, GOLD, centered=True)
        y -= 54
    rect(c, 24, 62, 792, 33, HexColor("#211911"), stroke=LINE)
    label(c, "가장 가까운 다음 안전 작업: P-05의 합/모션 연속 캡처와 소비처 검증. 사람 플레이 비교는 사용자가 유예한 별도 gate다.", PAGE_W / 2, 74, 8.2, normal, PAPER, centered=True)


def page_evidence(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 15, "이미지의 증거 상태", "승인 이미지 · 기계 런타임 캡처 · 아직 필요한 사람/기기 검증을 분리", normal, bold)
    draw_image(c, ASSETS["runtime_reveal"], 24, 256, 480, 300)
    rect(c, 24, 256, 480, 300, Color(0, 0, 0, alpha=0), stroke=LINE)
    callout(c, "✓", "실제 Godot 기계 캡처", "정면 대치, 거리 2, 3/3/4 계획 줄, 카드 격자, 잠금과 현재 행동 공개가 실제 화면에 존재한다.", 530, 458, 285, 78, normal, bold)
    callout(c, "✓", "승인된 시각 자산", "석정 background, 카드 atlas, attack-clash VFX, planning visual board는 final lock·consumer 상태를 가진다.", 530, 365, 285, 78, normal, bold)
    callout(c, "…", "아직 만들 캡처", "정확한 plan-locked, current-action reveal, impact/settle 화면은 project-bound session에서 추가로 캡처해야 한다.", 530, 272, 285, 78, normal, bold)
    rect(c, 24, 86, 792, 130, HexColor("#f1e5c9"), stroke=LINE)
    label(c, "이 PDF가 주장하지 않는 것", 42, 193, 13, bold)
    paragraph(c, "사람 플레이의 이해도 · Android 실제 기기 · 접근성 사용자 · 출시 성능 · 최종 연출 감각은 아직 검증하지 않았다. PDF의 이미지가 많아져도 이 증거 경계는 올라가지 않는다.", 42, 170, 730, size=10, leading=15, font=normal, color=MUTED)
    label(c, "다음 안전 작업: 정확한 Godot 세션에서 잠금·한 수 공개·합·정착을 연속 캡처하고, 이 PDF의 PENDING을 캡처 ID로 교체한다.", 42, 111, 9, bold, INK)


def page_handoff(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 16, "구현·발행 인계", "이미지 우선이지만 규칙·상태·검증 책임은 텍스트 정본과 Godot에 남긴다", normal, bold)
    draw_image(c, ASSETS["background"], 24, 250, 792, 274)
    rect(c, 24, 250, 792, 42, PANEL)
    label(c, "정면 석정은 전투의 큰 질량이다. 그러나 거리·현재 수·카드 사실보다 앞서면 안 된다.", PAGE_W / 2, 270, 11, bold, PAPER, centered=True)
    rows = [
        ("정본", "docs/design/2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md — 규칙과 UI 경계"),
        ("실제 화면", "TEN-RVC-20260901-001 / 005 — 기계 런타임 캡처"),
        ("승인 시각", "PROJECT_CORE_SCENE_VISUAL_BOARD_R2 + background/card/VFX asset consumers"),
        ("다음 캡처", "plan_locked → current-action reveal → impact → settle, 사람이 아닌 machine evidence로 먼저 기록"),
    ]
    y = 209
    for heading, body in rows:
        rect(c, 24, y - 20, 792, 30, HexColor("#f1e5c9"), stroke=LINE)
        label(c, heading, 38, y - 8, 9, bold, GOLD)
        label(c, body, 112, y - 8, 8.5, normal, MUTED)
        y -= 38
    rect(c, 24, 50, 792, 35, PANEL)
    label(c, "발행 원칙: 기존 승인 이미지를 제대로 소비하고, 실제 소비처가 없는 중복 이미지는 만들지 않는다.", PAGE_W / 2, 63, 9.2, bold, PAPER, centered=True)


def build(output: Path) -> None:
    must_exist()
    normal, bold = register_fonts()
    output.parent.mkdir(parents=True, exist_ok=True)
    with NamedTemporaryFile(prefix="ten-paces-blueprint-", suffix=".pdf", dir=output.parent, delete=False) as temp:
        temp_path = Path(temp.name)
    try:
        canvas = Canvas(str(temp_path), pagesize=landscape(A4), pageCompression=1)
        canvas.setTitle("십보강호 정면 결투 행동 흐름 · 이미지 중심 블루프린트")
        canvas.setAuthor("Ten Paces Hidden Moves")
        canvas.setSubject("Human GDD derived view; approved visual assets and machine runtime captures")
        page_cover(canvas, normal, bold); canvas.showPage()
        page_visual_direction(canvas, normal, bold); canvas.showPage()
        page_goal_system_map(canvas, normal, bold); canvas.showPage()
        page_plan_capture(canvas, normal, bold); canvas.showPage()
        page_flow_map(canvas, normal, bold); canvas.showPage()
        page_plan_wireframe(canvas, normal, bold); canvas.showPage()
        page_preparation_wireframe(canvas, normal, bold); canvas.showPage()
        page_card_art(canvas, normal, bold); canvas.showPage()
        page_combat_wireframe(canvas, normal, bold); canvas.showPage()
        page_reveal_wireframe(canvas, normal, bold); canvas.showPage()
        page_reveal_contract(canvas, normal, bold); canvas.showPage()
        page_image_production_pipeline(canvas, normal, bold); canvas.showPage()
        page_asset_lineage(canvas, normal, bold); canvas.showPage()
        page_case_status(canvas, normal, bold); canvas.showPage()
        page_evidence(canvas, normal, bold); canvas.showPage()
        page_handoff(canvas, normal, bold); canvas.showPage()
        canvas.save()
        os.replace(temp_path, output)
    finally:
        if temp_path.exists():
            temp_path.unlink()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    build(output)
    print(f"PDF_PUBLISHED {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
