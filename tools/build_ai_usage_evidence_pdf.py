"""Build a bounded, source-backed monthly evidence report; never overwrite an edition."""
import argparse
import hashlib
import json
import shutil
import subprocess
from datetime import datetime, timezone, timedelta
from pathlib import Path
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    spec = json.loads(args.manifest.read_text(encoding='utf-8'))
    output = args.output.resolve()
    if output.exists():
        raise FileExistsError('An issued edition must not be overwritten')
    evidence = output.with_name(output.stem + '_원본근거')
    if evidence.exists():
        raise FileExistsError('Evidence edition already exists')
    root = Path(spec['repository_root']).resolve()
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
    sources = []
    # Resolve and read every explicitly listed source before creating the edition.
    for item in spec['sources']:
        source = Path(item['path']).resolve()
        content = source.read_bytes()
        sources.append({**item, 'sha256': hashlib.sha256(content).hexdigest(),
                        'size': len(content), 'source_modified_at': datetime.fromtimestamp(
                            source.stat().st_mtime, timezone.utc).isoformat()})
    issued = datetime.now(timezone(timedelta(hours=9))).isoformat(timespec='seconds')
    output.parent.mkdir(parents=True, exist_ok=True)
    evidence.mkdir()
    for item in sources:
        target = evidence / (item['id'] + Path(item['path']).suffix)
        shutil.copy2(item['path'], target)
        if hashlib.sha256(target.read_bytes()).hexdigest() != item['sha256']:
            raise ValueError('Copied source mismatch')
        item['snapshot'] = target.name
    receipt = {'issued_at': issued, 'repository_head_at_issue': head, 'sources': sources,
               'report_spec': spec, 'submission_status': 'NOT_SUBMITTED'}
    (evidence / 'sources.json').write_text(json.dumps(receipt, ensure_ascii=False, indent=2), encoding='utf-8')
    pdfmetrics.registerFont(TTFont('Korean', spec['font_regular']))
    pdfmetrics.registerFont(TTFont('KoreanBold', spec['font_bold']))
    pdfmetrics.registerFontFamily('Korean', normal='Korean', bold='KoreanBold')
    ink = colors.HexColor('#18384A')
    body = ParagraphStyle('body', fontName='Korean', fontSize=10, leading=16, spaceAfter=8, wordWrap='CJK', textColor=ink)
    small = ParagraphStyle('small', parent=body, fontSize=8, leading=12, spaceAfter=5)
    heading = ParagraphStyle('heading', parent=body, fontName='KoreanBold', fontSize=18, leading=25, spaceAfter=17)
    sub = ParagraphStyle('sub', parent=body, fontName='KoreanBold', fontSize=12, leading=19, spaceBefore=7, spaceAfter=7)
    title = ParagraphStyle('title', parent=heading, fontSize=29, leading=39, spaceAfter=25)
    story = []
    def p(text, style=body):
        return Paragraph(escape(text).replace('\n', '<br/>'), style)
    def add(text, style=body):
        story.append(p(text, style))
    def table(rows, widths):
        cells = [[p(str(cell), small) for cell in row] for row in rows]
        t = Table(cells, colWidths=widths, repeatRows=1, hAlign='LEFT')
        t.setStyle(TableStyle([('BACKGROUND', (0,0),(-1,0),colors.HexColor('#E8EEF1')),
            ('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),8),
            ('RIGHTPADDING',(0,0),(-1,-1),8),('TOPPADDING',(0,0),(-1,-1),8),
            ('BOTTOMPADDING',(0,0),(-1,-1),6),('LINEBELOW',(0,0),(-1,-1),0.4,colors.HexColor('#CDD8DD'))]))
        story.append(t)
    add('십보강호', sub)
    add('AI 활용 작업일지\n증빙집', title)
    add('2026년 9월 | v1.0 | 확인 가능한 9월 12~14일 기록', sub)
    add('기존 개발 기록과 실제 결과물을 연결한 기간 보고서입니다. 게임 Blueprint와 기획 정본은 별도로 유지합니다. 지원사업 제출용 증빙 준비본이며, 제출·정산 인정·협약 체결 완료를 뜻하지 않습니다.')
    table([['구분', '기록 기준'],['대상 프로젝트','Ten-Paces-Hidden-Moves / 십보강호'],
           ['작성·발행일',issued + ' (한국 표준시)'],['실제 작업일','실행 기록과 Git 변경 시각을 대조. 정확한 AI 입력 시각은 별도 미확인.'],
           ['이전 작업 정리','9월 12~13일 내용은 기존 실행 기록을 이번 발행일에 사후 정리.'],
           ['증빙 범위','관련 문서·변경 기록·실행 로그·게임 캡처. 입력 화면·계정 식별정보·영수증 미첨부.']], [110,397])
    story.append(Spacer(1,15))
    add('PDF의 날짜와 파일 해시는 독립적인 시점 인증이 아닙니다. 각각 기록의 기준 시각과 원본 대조 수단으로 제공합니다.', small)
    story.append(PageBreak())
    add('01  날짜별 작업과 AI 활용', heading)
    table([['작업일 근거','작업 / 결과','상세'], *spec['timeline']], [88,349,70])
    add('사용 AI·계정 구분', sub)
    add('이 문서는 Codex로 작성했습니다. 개발 작업은 저장소 실행 기록에 기재된 Codex 구현·검증 활동을 기준으로 정리했습니다. 이전 작업의 세부 모델명·계정 소유자·결제 계정은 미확인입니다. ChatGPT 이미지 생성 비용이나 사용량을 임의로 합산하지 않았습니다.')
    add('입력 증빙 - 실제 요청 텍스트 발췌', sub)
    for quote in spec['prompt_excerpts']:
        add('“' + quote + '”', small)
    add('출처: 현재 사용자 대화에서 직접 발췌. 원래 입력 시각은 이 PDF에서 인증하지 않습니다. 화면 캡처가 아닌 텍스트 전사이며, 원본 대화 화면은 미첨부입니다.', small)
    add('결과 증빙 연결', sub)
    add('P01 코드 commit 59f72455, 후속 검사 교정 85cd53a3, 설계 명세와 실행 보고, 원본 로그·캡처 사본을 연결했습니다. Git commit 시각은 AI 입력의 정확한 시작·종료 시각을 증명하지 않습니다.')
    story.append(PageBreak())
    add('02  기존 화면과 플레이 흐름 개선', heading)
    for section in spec['historical_details']:
        add(section['title'], sub)
        add(section['body'])
    add('조사·비교와 채택한 구조', sub)
    add('기존 명세는 Shogun Showdown, Tactical Breach Wizards, Into the Breach, Fights in Tight Spaces 등 직접 비교 4개와 인접 게임 6개를 공식 자료로 비교합니다. 결과를 통해 학습하는 흐름, 상태별 선택 가치, 설정·진행 저장 분리, 작은 화면의 조작 도달성을 이 프로젝트에 맞게 적용했습니다. 덱·손패·드로우, 상대의 비공개 계획 전면 공개, 대규모 별도 설정 체계는 채택하지 않았습니다.')
    add('이는 기존 조사 기록의 사후 요약입니다. 외부 게임의 비공개 코드·개발 공정·성공 원인이나 대표적인 플레이어 반응을 직접 검증했다는 뜻이 아닙니다. 공식 출처와 ADAPT/AVOID 경계는 원본 S01의 20절에서 확인할 수 있습니다.', small)
    add('자체 검수의 주체와 한계', sub)
    add('자동 에이전트가 코드·회귀·실행 화면을 확인한 기록입니다. 사용자가 직접 플레이하거나 지원사업 담당자가 승인한 검수 서명으로 대체하지 않습니다. 실제 음향 장치·Android·실물 입력·사람 접근성 평가는 미실시입니다.')
    story.append(PageBreak())
    add('03  전수 무공의 실제 전투 연결', heading)
    add('작업 A-004 | 2026-09-14 | Codex | P01', sub)
    add('작업 전: 성장 기록에 전수된 무공이 추가되어도 일부 전투·봉인 선택·저장 검증은 시작 4권만 기준으로 삼았습니다. 획득 기록과 실제 사용 가능 기술이 어긋날 수 있었습니다.')
    add('이번 구현: 시작 4권 이력을 유지하면서 현재 보유 무공 목록을 따로 제공합니다. 전투 연결, 보상 대상 검사, 봉인 선택, 표시와 저장 검증이 이 목록을 사용합니다. 보상 이력은 당시 보유 상태로 검증하여 미래 전수로 과거의 잘못된 보상을 정당화하지 못하게 했습니다.')
    add('저장 호환: 구형 v1/v2 파일을 먼저 검증한 뒤 전투의 보유 연결만 복원합니다. 디스크 원본 해시와 실행 중 변환된 상태 해시를 구분해 기존 포인터의 무결성을 보존합니다. 새로운 자유 수련 배분 규칙은 이번 호환 교정에 섞지 않았습니다.')
    add('사용 예', sub)
    add('철검십식을 전수받은 뒤 다음 비무에서 해당 해금 기술을 1수에 배치하고 실제 해결합니다. 게임을 닫고 이어하기로 돌아온 뒤에도 그 무공을 사용할 수 있습니다. 보유 무공 5권/10권 검사는 합법적인 이력 fixture이며, 실제 자동 10전 완주는 별도의 보유 7권 경로입니다.')
    table([['검증 근거','결과 / 의미'],['보유·봉인 회귀 S03','472검사, 실패 0. 실제 봉인 선택과 다음 전투/저장 경계 포함.'],
           ['Windows GPU S04','22검사, 실패 0. 소스 프로젝트 실행의 화면 확인.'],
           ['실제 자동 입력 S05','10승 / 보상 10회 / 행로 36회 / 입력 286회 / 보유 7권 / 실패 0.'],
           ['Windows 배포 CI S07','d8e00379 빌드, 50/50 시나리오. 사람·기기·출시 검증과 구분.']], [145,362])
    add('실패와 교정도 보존', sub)
    add('구형 집중수련 전용 인수를 전수 캠페인에 적용한 실패와, 비무 UI 테스트가 시작 무공을 현재 목록으로 취급한 실패를 분리했습니다. 후자는 동일 RED 재현 후 BIMU_CONSTRAINT_UI_OK로 교정했습니다. d8e00379 전체 CI는 33 성공/1 실패였으며, 후속 85cd53a3 결과는 GitHub 최신 검사에서 확인합니다.', small)
    story.append(PageBreak())
    add('04  실제 결과 화면', heading)
    shot = next(s for s in sources if s['id'] == 'S06')
    picture = Image(str(evidence / shot['snapshot']))
    ratio = 507 / picture.imageWidth
    picture.drawWidth = 507
    picture.drawHeight = picture.imageHeight * ratio
    story.append(picture)
    story.append(Spacer(1,12))
    add('전수받은 철검십식의 해금 기술이 선택 영역과 1수 배치에 표시된 실제 Godot 화면입니다. 이미지 생성 시안이 아닙니다. 소스 실행 검증이며 다운로드한 배포 파일의 동일 화면을 직접 검증했다는 의미는 아닙니다.')
    add('캡처 시각 기록', sub)
    add('원본 PNG 파일의 수정 시각(UTC): ' + shot['source_modified_at'] + '. 한국 시각으로 2026-09-14 오전에 해당합니다. 파일 시스템 시각은 보조 정보이며 독립 인증이 아닙니다. 이번 PDF 발행일과 구분합니다.', small)
    add('실행·이미지 상태', sub)
    add('실제 Windows 소스 실행: 확인. 자동 입력 검증: 통과. 사용자 최종 화면 승인·재미 평가: 미실시. 모션 시트 4장의 최종 확정: 기존 대기 상태 유지. 이미지 생성 요청과 결과를 허위로 덧붙이지 않았습니다.')
    add('향후 이미지 기록 방식', sub)
    add('새 이미지는 크로마키 배경 생성 후 배경을 제거하고, 원본/투명 결과/가장자리 검수/사용자 최종 확정/실제 소비처를 따로 기록합니다. 이번 증빙집 작업에서 새 게임 이미지를 생성하거나 승인된 원화를 교체하지 않았습니다.')
    story.append(PageBreak())
    add('05  원본 대조와 변경 기록', heading)
    add('PDF 옆의 동일 이름 “원본근거” 폴더에 사본과 sources.json을 보관했습니다. S번호로 원본 위치·사본명·파일 크기·SHA-256·수정 시각을 찾을 수 있습니다. 해시는 내용 동일성 검사이며 신뢰기관의 타임스탬프가 아닙니다.', small)
    table([['ID','근거 사본 / SHA-256 앞 16자리'], *[[s['id'],s['label'] + '\n' + s['snapshot'] + ' / ' + s['sha256'][:16]] for s in sources]], [45,462])
    add('GitHub에서 변경 내용 확인', sub)
    for label, url in spec['links']:
        story.append(Paragraph(escape(label) + ' : <link href="' + escape(url) + '"><u>원본 열기</u></link>', small))
    add('이 발행본의 저장소 기준 HEAD: ' + head, small)
    story.append(PageBreak())
    add('06  남은 작업과 증빙 보완', heading)
    table([['순서','남은 구현 / 완료 근거'],['다음 P02','자유 수련 배분·취소·확정·저장·해금. 새 버전 사건 순서 검증과 기존 v1/v2 보존.'],
           ['P03~P07','시작/성장 능력, 중복 전수, 등급, 행로 보상, 회차 밖 기록. 후보 정책과 실제 구현 구분.'],
           ['P08~P11','화면/입력, 모션·음향, 다국어·접근성, Windows/Android adapter와 기기.'],
           ['계속 P12~P14','밸런스·저장/성능·전체 플레이 인수·권리·배포 준비. 자동 검사로 출시 승인 대체 금지.']], [90,417])
    add('제출 전 증빙 보완표', sub)
    table([['항목','현재 상태'],['실제 입력 화면','미첨부. 현재 요청의 텍스트 발췌만 수록.'],['계정/AI 솔루션 확인','Codex 사용 기록 있음. 계정 식별정보·청구 계정 대응은 미확인.'],
           ['결제·영수증','이번 보고 범위에서 미첨부. 비용 합계 미산정. 중복 비용 가산 없음.'],
           ['메일·협약 원문·지정 양식','직접 확인하지 않음. 사용자 제공 설명을 계약 확인 사실로 인용하지 않음.'],
           ['사용자 검수·제출','최종 사용자 검수 및 외부 제출 미실시. 지원 인정 여부 미확인.']], [145,362])
    add('운영 원칙', sub)
    add('기존 실행 기록에 작업일·변경분·검증 결과·원본 위치를 남기고 월별로 재출력합니다. 오류 발견 시 기존 발행본을 조용히 덮어쓰지 않고 버전과 정정 사유를 남깁니다. 영수증은 고유 항목을 한 번 기록하고 관련 작업이 참조하도록 합니다. 새 기획 정본이나 날짜 인증 문서를 만들지 않습니다.')
    add('이번 작성에서는 PDF·사본 생성과 대조만 수행했습니다. 협회에 회신·전자서명·자료 제출·결제하지 않았습니다.', small)
    def footer(canvas, doc):
        canvas.setStrokeColor(colors.HexColor('#CDD8DD'))
        canvas.line(44,40,A4[0]-44,40)
        canvas.setFont('Korean',8)
        canvas.setFillColor(ink)
        canvas.drawString(44,27,'십보강호 | 2026-09 AI 활용 작업일지·증빙집 | 증빙 준비본')
        canvas.drawRightString(A4[0]-44,27,str(doc.page))
    doc = SimpleDocTemplate(str(output), pagesize=A4, rightMargin=44,leftMargin=44,topMargin=44,bottomMargin=54,
                            title='십보강호 AI 활용 작업일지·증빙집 2026-09', author='Codex / 사용자 검수 전')
    doc.build(story, onFirstPage=footer, onLaterPages=footer)
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    (evidence / 'pdf-sha256.txt').write_text(digest + '  ' + output.name + '\n', encoding='utf-8')
    print(json.dumps({'pdf':str(output),'evidence':str(evidence),'sha256':digest,'sources':len(sources)},ensure_ascii=False))


if __name__ == '__main__':
    main()
