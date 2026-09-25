"""Register native screen captures and an already encoded 3/3/4 movie.

Does not generate art or claim a campaign win. Run only after both native capture
commands complete without errors. The frame count comes from the engine receipt.
"""
import json
import hashlib
import shutil
import subprocess
from pathlib import Path
from PIL import Image
from html_blueprint import ROOT, sha, read, git

OUT = 'docs/blueprint/evidence/ink-screens-20260925'
STYLE = 'docs/visual-assets/candidates/TEN-INK-STYLES-20260924'


def publish():
    for name, marker in [('screens-final.log','INK_SCREEN_CAPTURE count=9'),
                         ('runtime-capture.log','INK_COMBAT_RUNTIME failures=0')]:
        log = (ROOT/'output/ink-screen-validation'/name).read_text(encoding='utf-8')
        if marker not in log or 'ERROR:' in log:
            raise ValueError('Native capture did not pass: '+name)
    capture = read(ROOT, OUT+'/capture.json')
    capture['shots'] = [s for s in capture['shots'] if s['key'] not in ['resolution','four-slots']]
    motion = read(ROOT, 'output/ink-runtime/capture.json')
    for key, raw in [('resolution','resolved-damage'),('four-slots','four-slots')]:
        target = ROOT/OUT/(key+'.png')
        shutil.copyfile(ROOT/'output/ink-runtime'/(raw+'.png'), target)
        with Image.open(target) as im:
            size = list(im.size)
        capture['shots'].append(dict(key=key,path=target.relative_to(ROOT).as_posix(),
            sha256=sha(target),size=size,source='actual_resolver_fixed_plan_native_capture'))
    (ROOT/OUT/'capture.json').write_text(json.dumps(capture,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    for target, raw in [('runtime-contact','clash-contact'),('runtime-result','resolved-damage'),('runtime-four-slots','four-slots')]:
        shutil.copyfile(ROOT/'output/ink-runtime'/(raw+'.png'),ROOT/STYLE/'clash-v2'/(target+'.png'))
    fixture = read(ROOT, STYLE+'/clash-v2/bundle-fixtures.json')
    events = [e for bundle in fixture['bundles'] for e in bundle['result']['presentation_events']]
    movie = STYLE+'/clash-v2/runtime-bundles.mp4'
    poster = OUT+'/resolution.png'
    distinct = len({sha(p) for p in sorted((ROOT/'output/ink-runtime/frames').glob('*.jpg'))[:motion['frames']]})
    clip = dict(id='ink-current-3-3-4',title='수묵 합 · 실제 3수 / 3수 / 4수 연속 진행',
        card_ids=sorted({str(e['card_id']) for e in events if e.get('card_id')}),events=events,
        path=movie,path_sha256=sha(ROOT/movie),poster=poster,poster_sha256=sha(ROOT/poster),
        timeline=[],timeline_basis='NATIVE_FIXED_FPS_24',frames=motion['frames'],distinct_frames=distinct,
        visual_status='FRAME_CHANGES_OBSERVED',duration_seconds=round(motion['frames']/motion['fps'],3),
        audio='NOT_CAPTURED',evidence_kind='ACTUAL_RESOLVER_FIXED_PLAN_NATIVE_CAPTURE',
        scope='MAIN_SOURCE',source_revision=git('rev-parse','HEAD'),
        outcomes=sorted({e.get('outcome','') for e in events}-{''}),
        caption='현재 수묵 적용 · 실제 판정기 3/3/4수 고정 계획 녹화')
    binary, text = {}, {}
    for folder in ['src','data','scenes','assets']:
        for file in sorted((ROOT/folder).rglob('*')):
            if not file.is_file(): continue
            path = file.relative_to(ROOT).as_posix()
            if file.suffix in {'.gd','.json','.tscn','.tres'} and path != 'assets/ASSET_MANIFEST.json' and not path.startswith('assets/blueprint/'):
                text[path] = hashlib.sha256(file.read_text(encoding='utf-8').encode('utf-8')).hexdigest()
            elif file.suffix in {'.png','.jpg','.wav','.ogg'}:
                binary[path] = sha(file)
    for path in ['project.godot','tests/verify_ink_combat_runtime.gd','tools/capture_ink_screen_refresh.gd',STYLE+'/clash-v2/bundle-fixtures.json']:
        text[path] = hashlib.sha256((ROOT/path).read_text(encoding='utf-8').encode('utf-8')).hexdigest()
    manifest = dict(engine=motion['engine'],source_revision=git('rev-parse','HEAD'),
        source_state='working tree source hashes are authoritative for this capture',
        source_hashes=binary,source_text_hashes=text,text_hash_policy='UTF8_UNIVERSAL_NEWLINES',
        clips=[clip],method=motion['source'],native_receipt=motion,
        limits='Silent fixed plans; nine native UI captures. Result/rest do not prove a won campaign. Human/Android NOT_RUN.')
    (ROOT/OUT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (ROOT/STYLE/'clash-v2/runtime-capture.json').write_text(json.dumps(motion,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    candidates = read(ROOT, STYLE+'/candidates.json')
    def refresh(record):
        if isinstance(record,list):
            for child in record: refresh(child)
        elif isinstance(record,dict):
            file = record.get('file','')
            if isinstance(file,str) and file.startswith('clash-v2/runtime-') and (ROOT/STYLE/file).is_file():
                record.update(sha256=sha(ROOT/STYLE/file),bytes=(ROOT/STYLE/file).stat().st_size)
            if record.get('video')=='clash-v2/runtime-bundles.mp4':
                record.update(frames=motion['frames'],fps=motion['fps'],duration_seconds=clip['duration_seconds'],
                    current_capture_manifest=OUT+'/manifest.json',current_opponents=['masked_baekmujin','slot1_dogyeom'])
            for child in list(record.values()):
                if isinstance(child,(list,dict)): refresh(child)
    refresh(candidates)
    (ROOT/STYLE/'candidates.json').write_text(json.dumps(candidates,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    style = ROOT/STYLE/'index.html'
    html = style.read_text(encoding='utf-8')
    import re
    html = re.sub(r'실제 Godot 4.7.1 화면 · [0-9.]+초',f"실제 Godot 4.7.1 화면 · {clip['duration_seconds']}초",html)
    link = '<a href="../../../../output/blueprint/index.html#home/screens">새 메인·준비·브리핑·행로 화면과 코멘트 보기 →</a>'
    if link not in html:
        html = html.replace('<section class="motion" id="clash-preview"', '<p>'+link+'</p>\n<section class="motion" id="clash-preview"',1)
    style.write_text(html,encoding='utf-8')
    print(json.dumps({'frames':motion['frames'],'seconds':clip['duration_seconds'],'screens':len(capture['shots']),'distinct_frames':distinct}))


if __name__ == '__main__':
    publish()
