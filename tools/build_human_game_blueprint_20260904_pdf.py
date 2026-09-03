#!/usr/bin/env python3
"""Build the current human-facing Ten Paces Blueprint from 2026-09-04 canon.

The output is intentionally a new derived publication.  It does not mutate the
preserved 20260902 PDF because that file carries superseded two-node route,
standalone review, and two-step CTA surfaces.  Rules stay text-native in the
Markdown owners; this PDF is a human-readable atlas, flow, wireframe and PM
view over those owners.
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
DEFAULT_OUTPUT = ROOT / "exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260904.pdf"
ATLAS = ROOT / "docs/visual-assets/candidates/TEN-HUMAN-BLUEPRINT-20260904/TEN_PACES_3X3_SCREEN_ATLAS_20260904_v1.png"
PAGE_W, PAGE_H = landscape(A4)
PAGE_COUNT = 24
EXPECTED_ATLAS_SIZE = (1672, 941)

INK = HexColor("#12171d")
PANEL = HexColor("#1b222b")
PANEL_2 = HexColor("#26303b")
PAPER = HexColor("#e6dfcf")
PAPER_2 = HexColor("#d4c9b4")
GOLD = HexColor("#b99552")
GOLD_LIGHT = HexColor("#e0c783")
BLUE = HexColor("#7c9db6")
RED = HexColor("#b85f5c")
GREEN = HexColor("#6e9f83")
MUTED = HexColor("#9d9b95")
LINE = HexColor("#645942")


def register_fonts() -> tuple[str, str]:
    normal = Path(r"C:\Windows\Fonts\malgun.ttf")
    bold = Path(r"C:\Windows\Fonts\malgunbd.ttf")
    if not normal.is_file() or not bold.is_file():
        raise RuntimeError("Korean PDF fonts are unavailable: expected Malgun Gothic")
    pdfmetrics.registerFont(TTFont("TenPacesHuman", str(normal)))
    pdfmetrics.registerFont(TTFont("TenPacesHumanBold", str(bold)))
    return "TenPacesHuman", "TenPacesHumanBold"


def assert_inputs() -> None:
    if not ATLAS.is_file():
        raise FileNotFoundError(f"Missing atlas candidate: {ATLAS}")
    with Image.open(ATLAS) as image:
        if image.size != EXPECTED_ATLAS_SIZE:
            raise ValueError(f"Atlas size must be {EXPECTED_ATLAS_SIZE}, found {image.size}")


def fill_rect(c: Canvas, x: float, y: float, width: float, height: float, fill: Color, *, stroke: Color | None = None, alpha: float = 1.0) -> None:
    c.saveState()
    c.setFillColor(fill)
    if alpha < 1:
        c.setFillAlpha(alpha)
    if stroke is None:
        c.rect(x, y, width, height, stroke=0, fill=1)
    else:
        c.setStrokeColor(stroke)
        c.setLineWidth(0.8)
        c.rect(x, y, width, height, stroke=1, fill=1)
    c.restoreState()


def crop_image(image: Image.Image, width: float, height: float) -> Image.Image:
    target_ratio = width / height
    source_ratio = image.width / image.height
    if source_ratio > target_ratio:
        crop_width = int(image.height * target_ratio)
        left = (image.width - crop_width) // 2
        return image.crop((left, 0, left + crop_width, image.height))
    crop_height = int(image.width / target_ratio)
    top = (image.height - crop_height) // 2
    return image.crop((0, top, image.width, top + crop_height))


def draw_image(c: Canvas, source: Path, x: float, y: float, width: float, height: float, *, alpha: float = 1.0) -> None:
    with Image.open(source) as opened:
        image = crop_image(opened.convert("RGB"), width, height)
        target_w = max(1, round(width * 1.65))
        target_h = max(1, round(height * 1.65))
        image = image.resize((target_w, target_h), Image.Resampling.LANCZOS)
        stream = BytesIO()
        image.save(stream, format="JPEG", quality=84, optimize=True, progressive=True)
        stream.seek(0)
        c.saveState()
        if alpha < 1:
            c.setFillAlpha(alpha)
        c.drawImage(ImageReader(stream), x, y, width=width, height=height, mask="auto")
        c.restoreState()


def text(c: Canvas, value: str, x: float, y: float, size: float, font: str, color: Color = PAPER, *, centered: bool = False) -> None:
    c.setFont(font, size)
    c.setFillColor(color)
    if centered:
        c.drawCentredString(x, y, value)
    else:
        c.drawString(x, y, value)


def wrap(value: str, width: float, size: float) -> list[str]:
    max_chars = max(10, int(width / (size * 0.92)))
    lines: list[str] = []
    for paragraph in value.split("\n"):
        remainder = paragraph.strip()
        if not remainder:
            lines.append("")
        while len(remainder) > max_chars:
            split = remainder.rfind(" ", 0, max_chars + 1)
            if split < max_chars // 2:
                split = max_chars
            lines.append(remainder[:split].strip())
            remainder = remainder[split:].strip()
        if remainder:
            lines.append(remainder)
    return lines


def paragraph(c: Canvas, value: str, x: float, top: float, width: float, *, size: float, leading: float, font: str, color: Color = PAPER) -> float:
    current = top
    for line in wrap(value, width, size):
        text(c, line, x, current, size, font, color)
        current -= leading
    return current


def page_base(c: Canvas, number: int, title: str, subtitle: str, normal: str, bold: str) -> None:
    fill_rect(c, 0, 0, PAGE_W, PAGE_H, INK)
    fill_rect(c, 18, 18, PAGE_W - 36, PAGE_H - 36, PANEL, stroke=GOLD)
    fill_rect(c, 18, PAGE_H - 72, PAGE_W - 36, 54, INK, stroke=GOLD)
    text(c, "십보강호 · 숨은 수의 비무", 35, PAGE_H - 43, 10, bold, PAPER)
    text(c, title, PAGE_W / 2, PAGE_H - 45, 17, bold, PAPER, centered=True)
    text(c, subtitle, PAGE_W / 2, PAGE_H - 60, 8.4, normal, PAPER_2, centered=True)
    c.setStrokeColor(LINE)
    c.line(35, 35, PAGE_W - 35, 35)
    text(c, "사람용 Blueprint · 규칙 정본과 runtime 증거를 대체하지 않는 파생 문서", 35, 20, 7.4, normal, MUTED)
    text(c, f"{number} / {PAGE_COUNT}", PAGE_W - 35, 20, 7.4, normal, MUTED, centered=True)


def card(c: Canvas, x: float, y: float, width: float, height: float, title: str, body: str, state: str, normal: str, bold: str, *, accent: Color = GOLD) -> None:
    fill_rect(c, x, y, width, height, PANEL_2, stroke=LINE)
    fill_rect(c, x, y + height - 27, width, 27, INK, stroke=accent)
    text(c, title, x + 11, y + height - 18, 9.2, bold, PAPER)
    paragraph(c, body, x + 11, y + height - 43, width - 22, size=7.6, leading=10.5, font=normal, color=PAPER_2)
    fill_rect(c, x + 10, y + 9, width - 20, 17, INK, stroke=accent)
    text(c, state, x + width / 2, y + 14, 6.6, bold, accent, centered=True)


def mini_label(c: Canvas, value: str, x: float, y: float, width: float, normal: str, bold: str, *, active: bool = False) -> None:
    fill = GOLD if active else PAPER_2
    color = INK if active else PANEL
    fill_rect(c, x, y, width, 25, fill, stroke=GOLD)
    text(c, value, x + width / 2, y + 8, 7.5, bold if active else normal, color, centered=True)


def status_panel(c: Canvas, x: float, y: float, width: float, height: float, title: str, *, player: bool, normal: str, bold: str) -> None:
    fill_rect(c, x, y, width, height, PANEL, stroke=GOLD)
    # A combat HUD panel can be only 92 pt high beside the VS rail.  It still
    # must show all three numeric resources and the five momentum pips without
    # letting the inner-strength row collide with the momentum label.
    compact = height < 110
    title_size = 7.6 if compact else 9
    row_step = 13 if compact else 20
    row_height = 6 if compact else 9
    row_top = 28 if compact else 43
    text(c, title, x + 10, y + height - (15 if compact else 20), title_size, bold, PAPER)
    labels = [("체력", RED), ("기력", BLUE), ("내력", GREEN)]
    for index, (label, color) in enumerate(labels):
        row_y = y + height - row_top - index * row_step
        text(c, label, x + 10, row_y + 2, 6.5 if compact else 7.8, bold, PAPER_2)
        fill_rect(c, x + 44, row_y, width - 73, row_height, INK, stroke=LINE)
        fill_rect(c, x + 45, row_y + 1, (width - 75) * (0.77 - index * 0.12), row_height - 2, color)
        text(c, ("30/30", "5/5", "4/4")[index] if player else "?/?", x + width - 10, row_y + 1, 6.3 if compact else 7.2, bold, PAPER, centered=True)
    text(c, "절초 기세", x + 10, y + (8 if compact else 19), 6.5 if compact else 7.8, bold, PAPER_2)
    for index in range(5):
        c.setFillColor(GOLD if index < (4 if player else 3) else PANEL_2)
        c.setStrokeColor(GOLD)
        c.circle(x + 72 + index * (13 if compact else 17), y + (10 if compact else 23), 4 if compact else 5.5, fill=1, stroke=1)


def page_cover(c: Canvas, normal: str, bold: str) -> None:
    draw_image(c, ATLAS, 0, 0, PAGE_W, PAGE_H)
    fill_rect(c, 42, 74, PAGE_W - 84, 184, INK, stroke=GOLD, alpha=0.93)
    text(c, "십보강호: 숨은 수의 비무", PAGE_W / 2, 211, 29, bold, PAPER, centered=True)
    text(c, "1대1 심리·전술 로그라이트 · 사람용 Blueprint", PAGE_W / 2, 176, 14, normal, GOLD_LIGHT, centered=True)
    paragraph(c, "강호행에서 다음 비무를 준비하고, 비무에서 상대의 수를 읽어 승부한 뒤 다시 성장한다. 이 문서는 그 흐름을 화면·시스템·제작·검증 상태까지 하나로 읽게 한다.", 111, 143, PAGE_W - 222, size=10.2, leading=15, font=normal, color=PAPER)
    fill_rect(c, 42, 42, PAGE_W - 84, 22, PANEL, stroke=GOLD)
    text(c, "2026-09-04 · 3갈래 후보 × 4회 선택 · 문서/이미지 후보는 runtime·Human·권리·출시 PASS가 아님", PAGE_W / 2, 49, 7.7, normal, PAPER, centered=True)


def page_intro(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "프로젝트 소개", "무협 심리·전술 로그라이트의 한 문장과 핵심 경험", normal, bold)
    fill_rect(c, 42, 352, 758, 143, PAPER, stroke=GOLD)
    text(c, "숨은 수를 읽고, 다음 수를 준비한다.", 66, 458, 22, bold, INK)
    paragraph(c, "십보강호: 숨은 수의 비무는 1대1 카드 배틀 형식의 무협 심리·전술 로그라이트다. 플레이어는 기본 행동과 수련한 무공 기술을 카드로 사용해 행동을 정하고, 강한 카드 자체보다 상대의 행동과 상태를 파악해 다음 수를 예측하는 판단을 반복한다.", 66, 423, 697, size=10, leading=15, font=normal, color=INK)
    cards = [
        ("강호행", "다음 목적지를 고르고 수련·정보·대비를 통해 다음 비무를 준비한다.", "비전투 SYSTEM"),
        ("비무", "3/3/4 행동 묶음과 공개 상태를 바탕으로 서로의 수를 읽고 해결한다.", "전투 SYSTEM"),
        ("합", "같은 수의 실제 충돌에서만 양쪽 현재 카드와 결과 원인을 비교한다.", "현재 카드 VS"),
    ]
    for index, (heading, body, state) in enumerate(cards):
        card(c, 42 + index * 257, 130, 240, 192, heading, body, state, normal, bold)


def page_legend(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "읽는 법과 증거 상태", "사람용 설명, 구현 상태, 검증 증거를 하나로 섞지 않는다", normal, bold)
    legend = [
        ("USER_APPROVED_CURRENT", "사용자 최신 방향으로 확정된 규칙/화면 계약", GOLD),
        ("SPECIFIED", "Decision·와이어프레임·handoff가 있으나 runtime이 아직 없음", BLUE),
        ("IMPLEMENTED_LEGACY", "실제 코드가 남아 있으나 최신 사용자 계약과 다름", RED),
        ("MACHINE_VERIFIED", "자동 검증 또는 캡처가 특정 상태를 확인함", GREEN),
        ("NOT_RUN", "사람 UX, Android, 접근성 사용자, 권리·출시는 실행되지 않음", PAPER_2),
    ]
    y = 431
    for state, body, color in legend:
        fill_rect(c, 49, y, 176, 29, color, stroke=GOLD)
        text(c, state, 137, y + 10, 7.2, bold, INK, centered=True)
        fill_rect(c, 240, y, 555, 29, PANEL_2, stroke=LINE)
        text(c, body, 256, y + 10, 8.4, normal, PAPER)
        y -= 48
    fill_rect(c, 49, 100, 746, 76, INK, stroke=GOLD)
    text(c, "현재 핵심 판정", 69, 146, 11, bold, GOLD_LIGHT)
    paragraph(c, "강호행로 3갈래·4회 선택과 단일 행동 실행은 USER_APPROVED_CURRENT다. 현재 Godot는 2노드 경로와 두 단계 CTA를 유지하므로 IMPLEMENTED_LEGACY다. 이 PDF의 새 atlas는 GENERATED_CANDIDATE로 문서에만 사용된다.", 69, 127, 698, size=8.8, leading=12, font=normal, color=PAPER)
    text(c, "RUNTIME_IMPLEMENTATION_NOT_STARTED · document contract only", 595, 104, 7.2, bold, GOLD_LIGHT, centered=True)


def page_atlas(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "3×3 화면 아틀라스", "같은 그림체로 9개 화면의 정보 위계와 제작 범위를 맞춘다", normal, bold)
    draw_image(c, ATLAS, 42, 100, 758, 426)
    fill_rect(c, 42, 62, 758, 24, PANEL, stroke=GOLD)
    text(c, "1 메인  ·  2 시작 무공  ·  3 성장/구성  ·  4 강호행로  ·  5 비무 준비  ·  6 기본 전투  ·  7 합  ·  8 절초  ·  9 종료/보상", PAGE_W / 2, 70, 7.9, bold, PAPER, centered=True)


def page_screen_groups(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "아틀라스 번호와 실제 역할", "숫자는 화면의 순서가 아니라 플레이 흐름 안의 책임을 뜻한다", normal, bold)
    groups = [
        ("01 · 메인", "시작·이어하기·설정의 진입점. 기존 title identity는 별도 권리/asset record가 소유한다.", "ENTRY"),
        ("02 · 시작 무공", "6개 중 4개를 고른다. 덱·손패가 아니라 현재 해금 기술의 출발점을 정한다.", "LOADOUT"),
        ("03 · 성장/구성", "수련과 해금 기술을 읽는다. 성장은 판단을 대체하지 않고 대응 폭을 넓힌다.", "GROWTH"),
        ("04 · 강호행로", "3갈래 후보 중 하나를 4회 고르고 다음 비무 Briefing으로 간다.", "NON-COMBAT"),
        ("05 · 비무 준비", "상태, 계획, 5×2 행동, 상세와 관찰을 한 surface에서 편집한다.", "PREPARATION"),
        ("06~08 · 실행", "기본/합/절초 모두 현재 카드 compare rail과 VS를 공유한다.", "COMBAT"),
        ("09 · 종료/보상", "승패·실제 원인 요약·승리 보상만 보여 준다. 별도 복기 화면은 없다.", "RESULT"),
    ]
    for index, (heading, body, state) in enumerate(groups):
        row, col = divmod(index, 2)
        card(c, 43 + col * 385, 399 - row * 98, 365, 81, heading, body, state, normal, bold)


def page_route_flow(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "강호행로 · 3갈래 × 4회", "비무 사이에 네 개의 짧은 선택을 하나의 route surface에서 이어 간다", normal, bold)
    text(c, "비무 결과", 88, 454, 14, bold, PAPER)
    x_positions = [220, 367, 514, 661]
    for index, x in enumerate(x_positions):
        fill_rect(c, x, 401, 106, 92, PANEL_2, stroke=GOLD)
        text(c, f"{index + 1}단계", x + 53, 465, 10, bold, GOLD_LIGHT, centered=True)
        text(c, "후보 3개 중 1개", x + 53, 437, 8, normal, PAPER, centered=True)
        text(c, f"{index + 1}/4", x + 53, 414, 9, bold, GOLD, centered=True)
        if index < 3:
            text(c, "→", x + 126, 440, 22, bold, GOLD, centered=True)
    text(c, "→", 194, 440, 22, bold, GOLD, centered=True)
    text(c, "다음 Briefing", 736, 454, 12, bold, PAPER)
    fill_rect(c, 125, 318, 592, 42, INK, stroke=GOLD)
    text(c, "행로 선택 0/4  →  1/4  →  2/4  →  3/4  →  4/4", PAGE_W / 2, 333, 13, bold, GOLD_LIGHT, centered=True)
    items = [
        ("공개 전", "세 후보 모두 범주·즉시 효과·조건을 읽는다."),
        ("선택", "하나만 적용하고 선택 결과를 작은 strip으로 남긴다."),
        ("보호", "정답 수·AI 확률·현재/미래 잠금 계획은 보이지 않는다."),
        ("종료", "4번째 결과를 적용한 뒤 다음 상대 Briefing으로 이동한다."),
    ]
    for index, (heading, body) in enumerate(items):
        card(c, 43 + index * 190, 130, 172, 143, heading, body, "ROUTE CONTRACT", normal, bold)


def page_route_wireframe(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "강호행로 와이어프레임", "3개 lane × 4개 stage. 선택한 길은 다음 단계에서 다시 합류한다", normal, bold)
    fill_rect(c, 43, 104, 755, 400, PAPER_2, stroke=GOLD)
    text(c, "강호행로 선택", 420, 467, 19, bold, INK, centered=True)
    text(c, "이번 행로 선택 0/4 · 선택 가능한 길은 세 갈래입니다.", 420, 443, 9.2, normal, PANEL, centered=True)
    labels = ["1단계", "2단계", "3단계", "4단계"]
    lane_names = ["회복/성장", "정보/관찰", "사건/대비"]
    for column, label_value in enumerate(labels):
        x = 167 + column * 137
        mini_label(c, label_value, x, 403, 100, normal, bold, active=column == 0)
        for row, lane in enumerate(lane_names):
            y = 332 - row * 75
            fill_rect(c, x, y, 100, 47, PAPER, stroke=LINE)
            text(c, lane, x + 50, y + 27, 8.3, bold, INK, centered=True)
            text(c, "효과 한 줄", x + 50, y + 12, 6.7, normal, PANEL_2, centered=True)
            if column < 3:
                text(c, "→", x + 117, y + 17, 16, bold, GOLD, centered=True)
    fill_rect(c, 55, 206, 85, 146, PANEL, stroke=GOLD)
    text(c, "이전", 97, 321, 11, bold, PAPER, centered=True)
    text(c, "비무", 97, 294, 11, bold, PAPER, centered=True)
    fill_rect(c, 694, 206, 85, 146, PANEL, stroke=GOLD)
    text(c, "다음", 736, 321, 11, bold, PAPER, centered=True)
    text(c, "비무", 736, 294, 11, bold, PAPER, centered=True)
    text(c, "화면은 분기처럼 보이되, 각 단계에서 하나를 고르면 다음 세 후보로 합류한다. 자유 탐험 지도나 네 개의 별도 Scene이 아니다.", 420, 137, 8.4, normal, PANEL, centered=True)


def page_route_information(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "강호행로 후보 계약", "선택 결과는 다음 비무를 바꾸되 숨은 수를 정답으로 만들지 않는다", normal, bold)
    cards = [
        ("성장/회복", "체력·기력·내력의 회복, 현재 해금 기술의 수련, 준비 폭 확대. 무공서를 덱처럼 획득하지 않는다.", "PUBLIC PAYOFF", GREEN),
        ("정보/관찰", "공개 상태·보유 범위·정성 습관의 가설 재료. 기술명·대상·피해·확률·AI 계획은 숨긴다.", "TYPE-ONLY INFO", BLUE),
        ("사건/대비", "짧은 조건부 대비, 선택 비용 또는 작은 예외. 전투를 새로 추가하거나 전투 보정을 숨기지 않는다.", "NO EXTRA BATTLE", GOLD),
        ("거절", "동일 보상 세 개, 정답 행동 힌트, 확률 공개, 덱/손패/드로우, 자유 탐험 확장은 모두 거절한다.", "AVOID", RED),
    ]
    for index, (heading, body, state, accent) in enumerate(cards):
        row, col = divmod(index, 2)
        card(c, 50 + col * 381, 270 - row * 166, 356, 142, heading, body, state, normal, bold, accent=accent)
    fill_rect(c, 50, 88, 737, 44, INK, stroke=GOLD)
    text(c, "실제 시간 예산, 후보 반복성, 선택 만족도는 runtime·사람 플레이 전까지 NOT_RUN이다.", PAGE_W / 2, 104, 8.7, normal, PAPER, centered=True)


def page_route_pm(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "강호행로 PM 체크", "규칙, 화면, 데이터, 구현, 검증을 같은 단계표에서 분리한다", normal, bold)
    rows = [
        ("규칙", "3갈래 후보 × 4단계, 0/4 counter", "USER_APPROVED_CURRENT", GOLD),
        ("UX", "후보 범주·효과 공개, 정보 누출 금지", "SPECIFIED", BLUE),
        ("콘텐츠", "단계별 3후보 생성·효과 budget", "SPECIFIED", BLUE),
        ("Godot model", "2노드 Run route를 4 stage state로 교체", "NOT_STARTED", RED),
        ("Godot screen", "route shell 3-lane + counter + result strip", "NOT_STARTED", RED),
        ("자동 test", "선택 1회 적용·4회 뒤 Briefing·leak guard", "NOT_STARTED", RED),
        ("runtime", "Windows visible capture", "NOT_RUN", PAPER_2),
        ("human", "선택 이해·비전투 길이 playtest", "NOT_RUN", PAPER_2),
    ]
    y = 459
    for layer, deliverable, state, accent in rows:
        fill_rect(c, 49, y, 746, 36, PANEL_2, stroke=LINE)
        text(c, layer, 67, y + 13, 8.8, bold, PAPER)
        text(c, deliverable, 154, y + 13, 8.3, normal, PAPER_2)
        fill_rect(c, 612, y + 8, 165, 19, INK, stroke=accent)
        text(c, state, 694, y + 14, 6.7, bold, accent, centered=True)
        y -= 47


def page_bimu_flow(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "비무 Flow Map", "준비 → 단일 행동 실행 → 현재 카드 공개 → 해결/다음 수 → 결과", normal, bold)
    nodes = [
        ("Briefing", "공개 정보"),
        ("준비", "계획·카드"),
        ("행동 실행", "한 CTA"),
        ("현재 공개", "카드 VS"),
        ("해결", "합/중단"),
        ("결과", "원인 요약"),
    ]
    for index, (heading, body) in enumerate(nodes):
        x = 43 + index * 127
        fill_rect(c, x, 375, 105, 92, PANEL_2, stroke=GOLD if index in (2, 3) else LINE)
        text(c, heading, x + 52, 431, 9.4, bold, PAPER, centered=True)
        text(c, body, x + 52, 405, 7.7, normal, PAPER_2, centered=True)
        if index < len(nodes) - 1:
            text(c, "→", x + 115, 411, 18, bold, GOLD, centered=True)
    fill_rect(c, 128, 286, 583, 43, INK, stroke=GOLD)
    text(c, "3수 → 해결 → 3수 → 해결 → 4수 → 해결", PAGE_W / 2, 302, 13, bold, GOLD_LIGHT, centered=True)
    card(c, 52, 115, 345, 123, "플레이어가 조작", "기본/무공/절초 카드 선택, 현재 계획 편집, hover 상세·관찰 확인, 단일 행동 실행.", "PREPARATION ONLY", normal, bold)
    card(c, 444, 115, 345, 123, "끝까지 보호", "상대의 미래 행동, 정확한 비용·피해·대상·AI 가중치, 플레이어 미확정 계획의 AI 열람.", "HIDDEN PLAN", normal, bold, accent=RED)


def page_prep_wireframe(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "비무 준비 와이어프레임", "상단 20% · 정면 결투 50% · 하단 계획/선택 30%", normal, bold)
    fill_rect(c, 43, 88, 754, 414, PAPER_2, stroke=GOLD)
    fill_rect(c, 56, 406, 728, 82, PANEL, stroke=GOLD)
    status_panel(c, 67, 412, 242, 70, "나 · 수치 공개", player=True, normal=normal, bold=bold)
    status_panel(c, 531, 412, 242, 70, "상대 · 수치 비공개", player=False, normal=normal, bold=bold)
    fill_rect(c, 350, 412, 84, 70, INK, stroke=GOLD)
    text(c, "제1라운드", 392, 457, 8.5, bold, PAPER, centered=True)
    text(c, "거리 2", 392, 436, 9, bold, GOLD_LIGHT, centered=True)
    fill_rect(c, 56, 207, 728, 199, PANEL_2, stroke=LINE)
    text(c, "공유 석정 바닥 · 같은 foot anchor · 논리 10칸/바닥 숫자 비표시", 420, 388, 8.2, normal, PAPER_2, centered=True)
    text(c, "나", 185, 296, 24, bold, PAPER, centered=True)
    text(c, "거리 2", 420, 295, 18, bold, GOLD_LIGHT, centered=True)
    text(c, "상대", 650, 296, 24, bold, PAPER, centered=True)
    fill_rect(c, 56, 88, 728, 119, PANEL, stroke=GOLD)
    text(c, "현재 계획 · 1묶음 / 3수", 76, 174, 9.3, bold, PAPER)
    for index, label_value in enumerate(("1수 · 번개 베기", "2수 · 허공 밟기", "3수 · 신검 지세")):
        mini_label(c, label_value, 209 + index * 136, 159, 124, normal, bold)
    mini_label(c, "행동 실행", 628, 159, 136, normal, bold, active=True)
    for index, label_value in enumerate(("기본", "무공", "절초")):
        mini_label(c, label_value, 76 + index * 88, 120, 78, normal, bold, active=index == 0)
    text(c, "5×2 카드 격자 · 우측 상세 효과 · 상대 행동 관찰", 477, 127, 7.6, normal, PAPER_2)


def page_prep_information(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "준비 화면 정보 계약", "각 정보는 누가 읽고 언제 사라지는지까지 정한다", normal, bold)
    cards = [
        ("상태 HUD", "나: 체력 30/30, 기력 5/5, 내력 4/4. 상대: 동일 막대지만 정확한 숫자는 없음. 양쪽 절초 기세는 5칸.", "ALWAYS"),
        ("계획", "현재 묶음만 세 카드로 보인다. 3/3/4 cadence는 하단 보조 문구로 남고 미래 행동은 편집/노출하지 않는다.", "CURRENT GROUP"),
        ("카드", "기본 / 무공 / 절초 공통 5×2 grid. 이름, 슬롯수, 핵심 태그, 비용, 필요한 사거리만 항상 표시한다.", "5×2"),
        ("상세", "기술 이름 / 기력·내력·행동 슬롯 / 효과 / 사거리. image copy가 아니라 UI data binding이 소유한다.", "TEXT-NATIVE"),
        ("관찰", "[전조], [공격], [이동] 같은 유형만. 기술명·피해·방향·비용·AI 계획은 숨긴다.", "TYPE-ONLY"),
        ("CTA", "단 하나의 행동 실행. 누르면 실행 화면으로 바뀌고 하단 선택 surface가 숨는다.", "ONE CTA"),
    ]
    for index, (heading, body, state) in enumerate(cards):
        row, col = divmod(index, 3)
        card(c, 42 + col * 255, 335 - row * 176, 238, 150, heading, body, state, normal, bold)


def page_execute_transition(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "행동 실행 전환", "확정은 하나, 실행 중에는 계획 surface가 사라진다", normal, bold)
    states = [
        ("준비", "현재 3수 계획을 편집한다.", "카드/상세/관찰 visible", BLUE),
        ("행동 실행", "유효성 확인 뒤 즉시 전투 실행으로 진입한다.", "한 번의 player CTA", GOLD),
        ("실행", "상단 HUD와 중단 결투만 남긴다.", "하단 surface hidden", RED),
        ("다음 수", "현재 수 해결 뒤 다음 current action으로 이동한다.", "미래 행동 hidden", GREEN),
    ]
    for index, (heading, body, state, accent) in enumerate(states):
        x = 53 + index * 190
        card(c, x, 308, 162, 149, heading, body, state, normal, bold, accent=accent)
        if index < 3:
            text(c, "→", x + 177, 369, 22, bold, GOLD, centered=True)
    fill_rect(c, 74, 184, 692, 64, INK, stroke=GOLD)
    text(c, "사용자에게 '행동계획 잠금'을 별도 조작으로 보이지 않는다. lock은 resolver 내부의 확정 상태일 수 있으나 플레이어 표면은 단일 행동 실행이다.", 420, 218, 8.7, normal, PAPER, centered=True)
    text(c, "현재 runtime은 두 단계 CTA를 유지한다. 이 화면은 최신 명세이며 runtime implementation은 NOT_STARTED다.", 420, 196, 8.3, bold, GOLD_LIGHT, centered=True)


def compare_rail(c: Canvas, x: float, y: float, width: float, normal: str, bold: str, *, left: str, right: str) -> None:
    fill_rect(c, x, y, width, 70, INK, stroke=GOLD)
    fill_rect(c, x + 13, y + 10, 132, 50, PAPER_2, stroke=GOLD)
    fill_rect(c, x + width - 145, y + 10, 132, 50, PAPER_2, stroke=GOLD)
    text(c, left, x + 79, y + 38, 8.6, bold, INK, centered=True)
    text(c, right, x + width - 79, y + 38, 8.6, bold, INK, centered=True)
    text(c, "VS", x + width / 2, y + 27, 24, bold, GOLD_LIGHT, centered=True)


def page_base_combat(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "기본 전투 화면", "기본 실행도 현재 공개 카드 compare rail을 항상 쓴다", normal, bold)
    status_panel(c, 48, 409, 222, 92, "나 · 유랑 검객", player=True, normal=normal, bold=bold)
    status_panel(c, 571, 409, 222, 92, "상대 · 가면의 검객", player=False, normal=normal, bold=bold)
    compare_rail(c, 272, 421, 298, normal, bold, left="속공 1수", right="강공 2수")
    fill_rect(c, 48, 107, 744, 281, PANEL_2, stroke=LINE)
    text(c, "나", 194, 240, 30, bold, PAPER, centered=True)
    text(c, "거리 2", 420, 240, 18, bold, GOLD_LIGHT, centered=True)
    text(c, "상대", 647, 240, 30, bold, PAPER, centered=True)
    text(c, "공유 석정 바닥 · 정면 대치 · 같은 바닥선 · 하단 계획 surface 숨김", 420, 136, 8.6, normal, PAPER_2, centered=True)


def page_clash(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "합 연출 화면", "실제 충돌일 때만 두 현재 카드와 VS 위에서 흰금 접점을 강조한다", normal, bold)
    status_panel(c, 48, 409, 222, 92, "나 · 유랑 검객", player=True, normal=normal, bold=bold)
    status_panel(c, 571, 409, 222, 92, "상대 · 가면의 검객", player=False, normal=normal, bold=bold)
    compare_rail(c, 272, 421, 298, normal, bold, left="속공 1수", right="강공 2수")
    fill_rect(c, 48, 107, 744, 281, PAPER_2, stroke=GOLD)
    text(c, "나", 222, 203, 42, bold, INK, centered=True)
    text(c, "합", 420, 208, 50, bold, INK, centered=True)
    text(c, "상대", 618, 203, 42, bold, INK, centered=True)
    c.setStrokeColor(GOLD)
    c.setLineWidth(5)
    c.line(348, 245, 420, 210)
    c.line(492, 245, 420, 210)
    text(c, "흰금 접점 + 검은 건조 먹선 · 승/패/상쇄의 실제 결과만 표시", 420, 135, 8.6, normal, PANEL, centered=True)


def page_ultimate(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "절초 연출과 중단", "절초도 카드 비교를 유지하고, 중단은 공개된 현재 카드만 손상시킨다", normal, bold)
    status_panel(c, 48, 409, 222, 92, "나 · 유랑 검객", player=True, normal=normal, bold=bold)
    status_panel(c, 571, 409, 222, 92, "상대 · 가면의 검객", player=False, normal=normal, bold=bold)
    compare_rail(c, 272, 421, 298, normal, bold, left="절초 · 청해일섬", right="강공 2수")
    fill_rect(c, 48, 107, 744, 281, PANEL_2, stroke=LINE)
    for radius in (36, 62, 88):
        c.setStrokeColor(BLUE)
        c.setLineWidth(2.2)
        c.circle(390, 239, radius, stroke=1, fill=0)
    text(c, "절초", 190, 175, 43, bold, PAPER)
    text(c, "청백 내공 소용돌이 · 기세 5칸 · 과도한 광선 금지", 420, 136, 8.6, normal, PAPER_2, centered=True)
    for x, title, body, state, accent in (
        (80, "피격 중단", "공개된 현재 카드만 찢김/퇴색 [중단].", "CURRENT ONLY", RED),
        (435, "미래 행동 보호", "미래 카드/숨은 계획은 보이지도 손상되지도 않는다.", "HIDDEN", GREEN),
    ):
        fill_rect(c, x, 43, 328, 58, PANEL_2, stroke=LINE)
        text(c, title, x + 11, 82, 8.2, bold, PAPER)
        text(c, body, x + 11, 67, 7.1, normal, PAPER_2)
        fill_rect(c, x + 10, 48, 308, 13, INK, stroke=accent)
        text(c, state, x + 164, 51.5, 5.8, bold, accent, centered=True)


def page_result(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "전투 종료 · 보상", "별도 복기 화면 대신 실제 원인을 결과 strip 안에 남긴다", normal, bold)
    fill_rect(c, 51, 340, 740, 150, PAPER_2, stroke=GOLD)
    text(c, "승리", 231, 404, 46, bold, INK, centered=True)
    text(c, "실제 원인 1~3개", 537, 449, 12, bold, INK, centered=True)
    text(c, "[합]에서 속공 승리 · 거리 유지 · 상대 행동 중단", 537, 420, 9.5, normal, PANEL, centered=True)
    text(c, "다음 행동의 정답은 제시하지 않는다.", 537, 394, 8.5, normal, PANEL_2, centered=True)
    card(c, 52, 132, 225, 154, "결과", "승/패, 실제 자원/상태 변화, 재도전 조건을 명확히 한다.", "RESULT" , normal, bold)
    card(c, 309, 132, 225, 154, "보상", "승리 보상만 선택한다. 패배 결과에 보상/경로 이동을 섞지 않는다.", "REWARD" , normal, bold)
    card(c, 566, 132, 225, 154, "복기 흡수", "전투 중 result strip과 결과 원인 요약이 복기 역할을 한다. 독립 overlay/scene은 없다.", "NO SEPARATE REVIEW" , normal, bold, accent=RED)


def page_bimu_pm(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "비무 PM 체크", "규칙은 확정, 현재 product에는 legacy 구현이 남아 있다", normal, bold)
    rows = [
        ("HUD", "플레이어 current/max · 적 숫자 감춤 · 기세 5칸", "SPECIFIED", BLUE),
        ("준비", "20/50/30 · 5×2 · 상세·관찰 · 행동 실행", "SPECIFIED", BLUE),
        ("실행", "상단/중단만 · card VS compare rail", "SPECIFIED", BLUE),
        ("합/절초", "current cards, VS, 접점/소용돌이, current-only interruption", "SPECIFIED", BLUE),
        ("현재 Godot", "2단계 CTA와 기존 review carrier가 남아 있음", "IMPLEMENTED_LEGACY", RED),
        ("Build", "CombatProgressButton/route/ui handoff test-first package", "NOT_STARTED", RED),
        ("runtime", "새 계약 Windows capture", "NOT_RUN", PAPER_2),
        ("human/device", "판독성·입력·접근성·Android", "NOT_RUN", PAPER_2),
    ]
    y = 459
    for layer, deliverable, state, accent in rows:
        fill_rect(c, 49, y, 746, 36, PANEL_2, stroke=LINE)
        text(c, layer, 67, y + 13, 8.8, bold, PAPER)
        text(c, deliverable, 154, y + 13, 8.3, normal, PAPER_2)
        fill_rect(c, 612, y + 8, 165, 19, INK, stroke=accent)
        text(c, state, 694, y + 14, 6.7, bold, accent, centered=True)
        y -= 47


def page_asset_pipeline(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "이미지 제작 파이프라인", "전체 장면을 먼저 보고, 필요한 실제 consumer만 분리한 뒤 Godot에서 합성한다", normal, bold)
    steps = [
        ("1", "전체 아틀라스", "화면 간 그림체·색감·정보 위계를 먼저 검토한다.", "GENERATED_CANDIDATE"),
        ("2", "분리 brief", "배경, HUD, 계획, 상세, 관찰, 카드, battler, VFX의 실제 consumer를 명시한다.", "BRIEF_READY"),
        ("3", "단일 후보", "한 consumer의 상태군을 새 이미지 모델로 제작하고 검토한다.", "GENERATED_CANDIDATE"),
        ("4", "최종 lock", "사용자 lock 뒤 SHA/provenance/rights/consumer를 등록한다.", "USER_FINAL_LOCK"),
        ("5", "Godot 합성", "texture가 아닌 text-native data binding까지 연결해 runtime capture를 남긴다.", "IMPLEMENTED"),
    ]
    for index, (badge, heading, body, state) in enumerate(steps):
        x = 43 + index * 151
        fill_rect(c, x, 310, 133, 162, PANEL_2, stroke=GOLD)
        c.setFillColor(GOLD)
        c.circle(x + 66, 442, 16, fill=1, stroke=0)
        text(c, badge, x + 66, 436, 10, bold, INK, centered=True)
        text(c, heading, x + 66, 405, 9.2, bold, PAPER, centered=True)
        paragraph(c, body, x + 10, 381, 113, size=7.2, leading=9.6, font=normal, color=PAPER_2)
        text(c, state, x + 66, 325, 5.8, bold, GOLD_LIGHT, centered=True)
        if index < 4:
            text(c, "→", x + 142, 382, 20, bold, GOLD, centered=True)
    fill_rect(c, 72, 140, 697, 99, INK, stroke=GOLD)
    text(c, "이 atlas의 현재 상태", 93, 204, 11, bold, GOLD_LIGHT)
    paragraph(c, "TEN_PACES_3X3_SCREEN_ATLAS_20260904_v1은 문서 PDF가 소비하는 whole-scene candidate다. runtime texture가 아니며, 이미 final-locked인 기존 HUD/battler/background modules를 대체하지 않는다. 외부 reference의 이미지 픽셀은 build에 들어가지 않는다.", 93, 182, 645, size=8.7, leading=12, font=normal, color=PAPER)


def page_asset_register(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "분리 후보와 합성 표", "후보를 많이 만드는 것이 아니라 소비처와 상태군이 확인된 것만 제작한다", normal, bold)
    rows = [
        ("Whole atlas", "9-screen composition", "GENERATED_CANDIDATE / PDF consumer", "문서 후보"),
        ("Route frame", "3 lane + 0/4 counter", "BRIEF_READY", "후속 Godot"),
        ("Prep HUD", "numeric/hidden-value state", "EXISTING MODULE + SPEC UPDATE", "기존 교체 금지"),
        ("Plan/detail/observe", "5×2 / hover / type-only", "EXISTING MODULE + SPEC UPDATE", "기존 교체 금지"),
        ("Battlers", "idle/attack/evade/block/hit/ultimate", "STATE BRIEF REQUIRED", "후속 Godot"),
        ("Compare rail/VFX", "basic/clash/ultimate/interruption", "STATE BRIEF REQUIRED", "후속 Godot"),
    ]
    y = 450
    for element, contract, state, note in rows:
        fill_rect(c, 46, y, 752, 49, PANEL_2, stroke=LINE)
        text(c, element, 61, y + 28, 8.6, bold, PAPER)
        text(c, contract, 211, y + 28, 8, normal, PAPER_2)
        text(c, state, 474, y + 28, 7.1, bold, GOLD_LIGHT)
        text(c, note, 690, y + 28, 7.1, normal, PAPER_2)
        y -= 58
    fill_rect(c, 46, 70, 752, 42, INK, stroke=GOLD)
    text(c, "권리 상태: AI candidate와 reference 관계는 SHIPPING_RIGHTS_AND_FINAL_LOCK_REVIEW 전까지 RELEASE_BLOCKED_UNVERIFIED다.", 422, 85, 8, normal, PAPER, centered=True)


def page_handoff(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "Godot 구현 handoff", "문서가 요구하지만 아직 product source에 없는 바뀜을 명확히 분리한다", normal, bold)
    cards = [
        ("Route model", "`vertical_slice_route_model.gd`: 성장 1회 + 정보 1회의 legacy route를 stage 4 / candidates 3 / selected once로 교체한다.", "LEGACY → BUILD"),
        ("Route shell", "`vertical_slice_shell_route_auto.gd`: vertical 버튼 대신 3 lane, 0/4 counter, applied-result strip과 Briefing handoff를 만든다.", "LEGACY → BUILD"),
        ("CTA", "`combat_progress_button.gd`: player-facing lock/N수 실행 두 단계를 단일 행동 실행으로 바꾸고 resolver count를 test한다.", "LEGACY → BUILD"),
        ("Surface", "계획 hidden, current card VS, no standalone Review, current-only interruption을 scene/controller contract로 구현한다.", "SPEC → BUILD"),
        ("Assets", "새 state module은 brief→candidate→user lock→manifest→composition 순서로만 넣는다.", "NO SILENT REPLACE"),
        ("Tests", "route, UI state, reveal boundary, interruption, current/max / hidden enemy numeric tests를 먼저 RED로 만든다.", "TEST-FIRST"),
    ]
    for index, (heading, body, state) in enumerate(cards):
        row, col = divmod(index, 2)
        card(c, 42 + col * 385, 359 - row * 153, 365, 130, heading, body, state, normal, bold, accent=RED if "LEGACY" in state else GOLD)


def page_verification(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "검증 매트릭스", "이 문서가 실제로 증명하는 범위와 아직 증명하지 않는 범위를 나눈다", normal, bold)
    rows = [
        ("문서/정본", "Decision, GDD, registry, status가 3갈래·4회와 CTA를 같은 의미로 가리킴", "MACHINE_VERIFIED"),
        ("PDF 구조", "24 pages, title/text markers, candidate asset and build source", "MACHINE_VERIFIED"),
        ("PDF 시각", "Poppler all-page render, glyph/crop/spacing/page-number inspection", "MACHINE_VERIFIED"),
        ("Godot automated", "new route/CTA/reveal regression", "NOT_RUN"),
        ("Windows runtime", "new route/prep/execution capture", "NOT_RUN"),
        ("Human UX", "route meaning, card detail readability, compare rail clarity", "NOT_RUN"),
        ("Android/accessibility", "touch/safe-area/focus/reduced motion/user validation", "NOT_RUN"),
        ("Rights/release", "AI terms/input rights/final asset/marketing/build review", "RELEASE_BLOCKED_UNVERIFIED"),
    ]
    y = 458
    for layer, evidence, state in rows:
        accent = GREEN if state == "MACHINE_VERIFIED" else (RED if state == "RELEASE_BLOCKED_UNVERIFIED" else PAPER_2)
        fill_rect(c, 49, y, 746, 36, PANEL_2, stroke=LINE)
        text(c, layer, 66, y + 13, 8.5, bold, PAPER)
        text(c, evidence, 180, y + 13, 7.9, normal, PAPER_2)
        fill_rect(c, 620, y + 8, 157, 19, INK, stroke=accent)
        text(c, state, 698, y + 14, 6.5, bold, accent, centered=True)
        y -= 47


def page_adversarial(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "5회 적대 검토", "한 방향의 완성도 대신 코어·정보·소비처·권리·증거를 각각 공격한다", normal, bold)
    loops = [
        ("1 · 코어", "3갈래·4회가 deck/hand/draw, 새 전투, 논리 10칸 변경을 끼워 넣지 않는지", "유지"),
        ("2 · 정보", "정보 후보가 상대의 계획·확률·정답을 누출하지 않는지", "유지"),
        ("3 · 화면", "4회 선택이 4개 Scene과 클릭 지연으로 늘어나지 않는지", "단일 surface"),
        ("4 · 자산", "새 atlas가 locked runtime asset을 조용히 교체하거나 shipping 권리를 주장하지 않는지", "candidate-only"),
        ("5 · 증거", "PDF/문서 PASS를 Godot/Human/Android/release PASS로 과장하지 않는지", "ceiling 유지"),
    ]
    y = 440
    for index, (heading, attack, result) in enumerate(loops):
        fill_rect(c, 57, y, 730, 58, PANEL_2, stroke=GOLD if index == 4 else LINE)
        text(c, heading, 74, y + 34, 9, bold, GOLD_LIGHT)
        text(c, attack, 190, y + 34, 8.3, normal, PAPER)
        text(c, result, 733, y + 34, 8, bold, GOLD_LIGHT, centered=True)
        y -= 70
    fill_rect(c, 57, 78, 730, 44, INK, stroke=GOLD)
    text(c, "CLEAN EXIT의 조건은 문서·PDF·reference checks 결과로만 판단한다. product runtime에는 별도의 implementation package가 필요하다.", 422, 94, 8.2, normal, PAPER, centered=True)


def page_risk(c: Canvas, number: int, normal: str, bold: str) -> None:
    page_base(c, number, "다음 안전 작업과 남은 위험", "현재 완료되는 것은 정본·후보·사람용 문서이며, 게임 구현 완료가 아니다", normal, bold)
    cards = [
        ("즉시 완료 대상", "3갈래·4회 Decision, benchmark, candidate provenance, current human PDF, registry/status/operation evidence.", "DOCUMENT PACKAGE"),
        ("다음 Build", "Godot route model/shell, one CTA, execution surface/reveal contract를 test-first implementation package로 만든다.", "SEPARATE AUTHORITY"),
        ("사용자 검수", "atlas는 documentation candidate다. runtime split-art 또는 shipping promotion 전에는 state-by-state visual final lock이 필요하다.", "FINAL LOCK LATER"),
        ("남은 위험", "선택이 길어질 수 있음, candidate Korean copy가 binding copy가 아님, route balance and human readability는 아직 검증되지 않음.", "NOT_RUN"),
    ]
    for index, (heading, body, state) in enumerate(cards):
        row, col = divmod(index, 2)
        card(c, 50 + col * 381, 332 - row * 175, 356, 149, heading, body, state, normal, bold, accent=GOLD if index < 2 else RED)
    fill_rect(c, 50, 71, 737, 44, INK, stroke=GOLD)
    text(c, "최종 현재 문서: HUMAN_GAME_BLUEPRINT_20260904 · 규칙 정본: 2026-09-04 Decision · runtime truth: actual code/tests/captures", PAGE_W / 2, 87, 8.1, normal, PAPER, centered=True)


PAGE_BUILDERS = (
    page_cover,
    page_intro,
    page_legend,
    page_atlas,
    page_screen_groups,
    page_route_flow,
    page_route_wireframe,
    page_route_information,
    page_route_pm,
    page_bimu_flow,
    page_prep_wireframe,
    page_prep_information,
    page_execute_transition,
    page_base_combat,
    page_clash,
    page_ultimate,
    page_result,
    page_bimu_pm,
    page_asset_pipeline,
    page_asset_register,
    page_handoff,
    page_verification,
    page_adversarial,
    page_risk,
)


def build(output: Path) -> None:
    assert_inputs()
    normal, bold = register_fonts()
    output.parent.mkdir(parents=True, exist_ok=True)
    with NamedTemporaryFile(prefix="ten-paces-human-blueprint-20260904-", suffix=".pdf", dir=output.parent, delete=False) as stream:
        temp_path = Path(stream.name)
    try:
        canvas = Canvas(str(temp_path), pagesize=landscape(A4), pageCompression=1)
        canvas.setTitle("십보강호 Human Game Blueprint · 2026-09-04")
        canvas.setAuthor("Ten Paces Hidden Moves")
        canvas.setSubject("Three-branch four-choice Jianghu Journey, Bimu wireframes, candidate atlas, PM and evidence boundaries")
        for number, page in enumerate(PAGE_BUILDERS, start=1):
            if page is page_cover:
                page(canvas, normal, bold)
            else:
                page(canvas, number, normal, bold)
            canvas.showPage()
        canvas.save()
        if len(PAGE_BUILDERS) != PAGE_COUNT:
            raise AssertionError(f"expected {PAGE_COUNT} builders, found {len(PAGE_BUILDERS)}")
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
