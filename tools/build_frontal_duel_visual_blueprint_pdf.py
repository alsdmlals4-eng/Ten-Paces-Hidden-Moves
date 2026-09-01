#!/usr/bin/env python3
"""Publish the image-centred human PDF for the frontal-duel blueprint.

The Markdown blueprint remains the canonical rule and interaction source.  This
script deliberately uses approved project imagery and machine runtime captures
for the derived PDF so a generic diagram never replaces the visual contract.
"""

from __future__ import annotations

import argparse
import os
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
DEFAULT_OUTPUT = ROOT / "output/pdf/TEN_PACES_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT_2026-09-02.pdf"
PAGE_W, PAGE_H = landscape(A4)

ASSETS = {
    "runtime_plan": ROOT / "docs/evidence/runtime-captures/TEN-RVC-20260901-001.png",
    "runtime_attack": ROOT / "docs/evidence/runtime-captures/TEN-RVC-20260901-005.png",
    "visual_board": ROOT / "docs/visual-assets/planning/PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2.png",
    "background": ROOT / "assets/backgrounds/frontal_courtyard_duel_background_01_v1.png",
    "card_atlas": ROOT / "assets/ui/cards/martial_ultimate_card_illustration_atlas_01_v1.png",
}

PAPER = HexColor("#e6d7b6")
INK = HexColor("#17130f")
GOLD = HexColor("#bd8c37")
MUTED = HexColor("#6f6049")
PANEL = HexColor("#211911")
LINE = HexColor("#715a35")


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


def draw_image(c: Canvas, source: Path, x: float, y: float, width: float, height: float, *, alpha: float = 1.0) -> None:
    with Image.open(source) as opened:
        crop = fit_crop(opened.convert("RGBA"), width, height)
        reader = ImageReader(crop)
        c.saveState()
        if alpha < 1:
            c.setFillAlpha(alpha)
        c.drawImage(reader, x, y, width=width, height=height, mask="auto")
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
    label(c, f"{number} / 7", PAGE_W - 26, 16, 8, normal, MUTED, centered=True)


def callout(c: Canvas, number: str, heading: str, body: str, x: float, y: float, width: float, height: float, normal: str, bold: str) -> None:
    rect(c, x, y, width, height, HexColor("#f1e5c9"), stroke=LINE)
    rect(c, x + 8, y + height - 30, 23, 20, GOLD)
    label(c, number, x + 19.5, y + height - 24, 10, bold, INK, centered=True)
    label(c, heading, x + 39, y + height - 23, 10, bold)
    paragraph(c, body, x + 12, y + height - 45, width - 24, size=8, leading=11, font=normal, color=MUTED)


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


def page_plan_capture(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 3, "계획 편집 · 실제 Godot 화면", "기계 런타임 캡처 TEN-RVC-20260901-001", normal, bold)
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
    label(c, "캡처가 보여주는 것: 계획 편집·카드 사실·현재 수.  아직 보이지 않는 잠금/공개/합은 다음 페이지에서 ‘구현 계약’으로만 표시한다.", PAGE_W / 2, 80, 8.2, normal, MUTED, centered=True)


def page_card_art(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 4, "통합 카드 · 삽화와 사실 정보", "카드 그림은 장식이 아니라 행동 출처를 빠르게 읽는 보조 채널", normal, bold)
    draw_image(c, ASSETS["card_atlas"], 24, 180, 493, 286)
    rect(c, 24, 180, 493, 286, Color(0, 0, 0, alpha=0), stroke=LINE)
    draw_image(c, ASSETS["runtime_attack"], 24, 60, 493, 100)
    rect(c, 24, 60, 493, 100, Color(0, 0, 0, alpha=0), stroke=LINE)
    label(c, "실제 카드 rack · 선택된 속공은 사거리 1·기력 1·내력 0·효과를 같은 면에서 읽는다.", 27, 48, 7.5, normal, MUTED)
    callout(c, "A", "항상 보임", "삽화 · 이름 · N수 · 출처 · 유형 · 기력/내력/기세 · 짧은 효과", 545, 391, 270, 75, normal, bold)
    callout(c, "B", "조건부 보임", "공격일 때 사거리, 절초일 때 예약/잠금 사유. 이동/자신 행동에는 가짜 사거리를 쓰지 않는다.", 545, 303, 270, 75, normal, bold)
    callout(c, "C", "상세 패널로 이동", "장문 조건·다단계 효과·풍미 텍스트만 상세로 보낸다. 비용이나 한 줄 효과는 숨기지 않는다.", 545, 215, 270, 75, normal, bold)
    callout(c, "D", "상태도 같은 언어", "선택·focus·disabled·locked·reserved를 색만이 아니라 테두리·문구·상세 설명으로 함께 전달한다.", 545, 127, 270, 75, normal, bold)


def page_reveal_contract(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 5, "잠금 → 한 수 공개 → 합 → 정착", "계획 이후의 표현 계약 · 실제 캡처와 아직 필요한 capture를 엄격히 구분", normal, bold)
    # Three image-led stages.
    stages = [
        ("계획 잠금", ASSETS["runtime_plan"], "현재 묶음만 고정하고 카드 배치를 닫는다.", "PENDING: exact plan-locked capture"),
        ("한 수 공개", ASSETS["card_atlas"], "양측의 현재 행동 카드만 대조한다.", "PENDING: project-bound reveal capture"),
        ("합·정착", ASSETS["visual_board"], "해결 사건 뒤 짧은 충돌과 거리 갱신을 보여준다.", "PENDING: project-bound impact capture"),
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


def page_evidence(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 6, "이미지의 증거 상태", "승인 이미지 · 기계 런타임 캡처 · 아직 필요한 사람/기기 검증을 분리", normal, bold)
    draw_image(c, ASSETS["runtime_attack"], 24, 256, 480, 300)
    rect(c, 24, 256, 480, 300, Color(0, 0, 0, alpha=0), stroke=LINE)
    callout(c, "✓", "실제 Godot 기계 캡처", "정면 대치, 거리 2, 3/3/4 계획 줄, 카드 격자, 자동 공격 배치가 실제 화면에 존재한다.", 530, 458, 285, 78, normal, bold)
    callout(c, "✓", "승인된 시각 자산", "석정 background, 카드 atlas, attack-clash VFX, planning visual board는 final lock·consumer 상태를 가진다.", 530, 365, 285, 78, normal, bold)
    callout(c, "…", "아직 만들 캡처", "정확한 plan-locked, current-action reveal, impact/settle 화면은 project-bound session에서 추가로 캡처해야 한다.", 530, 272, 285, 78, normal, bold)
    rect(c, 24, 86, 792, 130, HexColor("#f1e5c9"), stroke=LINE)
    label(c, "이 PDF가 주장하지 않는 것", 42, 193, 13, bold)
    paragraph(c, "사람 플레이의 이해도 · Android 실제 기기 · 접근성 사용자 · 출시 성능 · 최종 연출 감각은 아직 검증하지 않았다. PDF의 이미지가 많아져도 이 증거 경계는 올라가지 않는다.", 42, 170, 730, size=10, leading=15, font=normal, color=MUTED)
    label(c, "다음 안전 작업: 정확한 Godot 세션에서 잠금·한 수 공개·합·정착을 연속 캡처하고, 이 PDF의 PENDING을 캡처 ID로 교체한다.", 42, 111, 9, bold, INK)


def page_handoff(c: Canvas, normal: str, bold: str) -> None:
    page_shell(c, 7, "구현·발행 인계", "이미지 우선이지만 규칙·상태·검증 책임은 텍스트 정본과 Godot에 남긴다", normal, bold)
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
        page_plan_capture(canvas, normal, bold); canvas.showPage()
        page_card_art(canvas, normal, bold); canvas.showPage()
        page_reveal_contract(canvas, normal, bold); canvas.showPage()
        page_evidence(canvas, normal, bold); canvas.showPage()
        page_handoff(canvas, normal, bold); canvas.showPage()
        canvas.save()
        os.replace(temp_path, output)
    finally:
        if temp_path.exists():
            temp_path.unlink()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    output = args.output.resolve()
    build(output)
    print(f"PDF_PUBLISHED {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
