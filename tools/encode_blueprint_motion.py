"""Publish timestamp-preserving videos from the actual Godot viewport capture.

Requires a local ffmpeg binary (--ffmpeg); never installs or changes global tools.
Raw frames and logs remain in the ignored capture directory for diagnosis.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import re
from PIL import Image
from html_blueprint import ROOT, git, sha
from html_blueprint_experience import observed_timeline


def capture_dependencies(available):
    """Follow literal resources; keep all data/combat code for dynamic lookup safety.

    Unknown expressions are not evidence that a resource is unused. All captured
    data and combat modules remain in scope; referenced scene art follows literals.
    """
    classes = {}
    for path in available:
        if path.endswith('.gd'):
            match = re.search(r'^class_name\s+(\w+)', (ROOT/path).read_text(encoding='utf-8'), re.M)
            if match: classes[match.group(1)] = path
    pending = ['project.godot','tools/capture_blueprint_motion.gd',
               'scenes/combat/combat_board_preview.tscn',
               'src/run/vertical_slice_metrics_combat_resolution_engine.gd']
    pending += [p for p in available if p.startswith(('data/', 'src/combat/'))]
    seen = set()
    while pending:
        path = pending.pop()
        if path in seen: continue
        seen.add(path)
        file = ROOT/path
        if file.is_file() and file.suffix in {'.gd','.json','.tscn','.tres','.godot'}:
            text = file.read_text(encoding='utf-8')
            pending.extend(classes[name] for name in set(re.findall(r'\b[A-Za-z_]\w*\b',text)) & classes.keys() if classes[name] not in seen)
            for target in re.findall(r'res://([^"\s)]+)', text):
                if target in available and target not in seen: pending.append(target)
                elif (ROOT/target).is_dir():
                    pending.extend(p for p in available if p.startswith(target.rstrip('/')+'/'))
            for target in re.findall(r'extends\s+"([^"\n]+)"', text):
                relative = (file.parent/target).resolve()
                if relative.is_relative_to(ROOT):
                    target = relative.relative_to(ROOT).as_posix()
                    if target in available: pending.append(target)
    return sorted(seen & set(available))


def encode(ffmpeg, log='stderr-5.log'):
    capture = ROOT/'output/blueprint/motion-capture'
    if (capture/log).read_text(encoding='utf-8').strip():
        raise ValueError('Godot capture reported errors; do not publish')
    success_log = capture/log.replace('stderr','stdout')
    if 'BLUEPRINT_MOTION_CAPTURE_OK 36' not in success_log.read_text(encoding='utf-8'):
        raise ValueError('Missing successful complete capture')
    record = json.loads((capture/'frames.json').read_text(encoding='utf-8'))
    if len(record['clips']) != 36:
        raise ValueError('Expected six presentation scenarios and thirty manual cards')
    out = ROOT/'docs/blueprint/evidence/motion'
    out.mkdir(parents=True, exist_ok=True)
    names = {'clash-win':'격돌 → 합 승리 → 공격', 'clash-lose':'격돌 → 합 패배 → 피격',
             'hit':'공격 · 피격 · 복귀', 'block':'방어 결과 표시',
             'evade':'회피 결과 표시', 'ultimate':'절초 · 타격 · 복귀'}
    clips = []
    for clip in record['clips']:
        frames = record['frames'][clip['start_frame']:clip['end_frame']]
        if len(frames) < 10:
            raise ValueError('Truncated capture: '+clip['id'])
        lines = []
        for i, frame in enumerate(frames):
            duration = (frames[i+1]['ms']-frame['ms'])/1000 if i+1<len(frames) else 1/30
            lines.extend(["file '"+frame['file']+"'", 'duration '+str(duration)])
        lines.append("file '"+frames[-1]['file']+"'")
        listing = capture/'encode-frames.txt'
        listing.write_text('\n'.join(lines)+'\n', encoding='utf-8')
        movie = out/(clip['id']+'.mp4')
        subprocess.run([ffmpeg,'-hide_banner','-loglevel','error','-y','-f','concat','-safe','1',
                        '-i',str(listing),'-vf','fps=30,scale=960:600','-c:v','libx264','-crf','23',
                        '-pix_fmt','yuv420p','-movflags','+faststart','-an',str(movie)], check=True)
        poster = out/(clip['id']+'.jpg')
        with Image.open(capture/frames[len(frames)//2]['file']) as im:
            im.resize((960,600)).save(poster,quality=85)
        distinct = len({sha(capture/f['file']) for f in frames})
        # Detect a frozen arena even if a label elsewhere changes.
        arena_distinct = set()
        for frame in frames:
            with Image.open(capture/frame['file']) as im:
                arena_distinct.add(hashlib.sha256(im.crop((0,150,1280,510)).tobytes()).hexdigest())
        if clip['id'] in {'clash-win','clash-lose','hit','ultimate'} and len(arena_distinct) <= 1:
            raise ValueError('Frozen arena presentation: '+clip['id'])
        event = clip['events'][-1]
        clips.append({'id':clip['id'],'title':names.get(clip['id'],event.get('card_name',clip['id'])),
            'card_ids':sorted({e['card_id'] for e in clip['events']}), 'events':clip['events'],
            'path':movie.relative_to(ROOT).as_posix(),'path_sha256':sha(movie),
            'poster':poster.relative_to(ROOT).as_posix(),'poster_sha256':sha(poster),
            'timeline': observed_timeline(frames),
            'timeline_basis': 'ENGINE_PHASE_AT_RENDERED_FRAME',
            'frames':len(frames),'distinct_frames':distinct,'arena_distinct_frames':len(arena_distinct),
            'visual_status':'FRAME_CHANGES_OBSERVED' if len(arena_distinct)>5 else 'STATIC_OR_EFFECT_ONLY',
            'duration_seconds':round((frames[-1]['ms']-frames[0]['ms'])/1000+1/30,3),
            'audio':'NOT_CAPTURED', 'evidence_kind':'GODOT_PRESENTATION_FIXTURE_CAPTURE',
            'scope':'MAIN_SOURCE','source_revision':git('rev-parse','HEAD'),
            'outcomes':sorted({e.get('outcome','') for e in clip['events']})})
    text_hashes, binary_hashes = {}, {}
    paths = git('ls-files','src','data','scenes','assets').splitlines()+['project.godot','tools/capture_blueprint_motion.gd']
    for path in paths:
        file = ROOT/path
        if file.suffix in {'.gd','.json','.tscn','.tres','.godot'}:
            text_hashes[path] = hashlib.sha256(file.read_text(encoding='utf-8').encode('utf-8')).hexdigest()
        elif file.suffix in {'.png','.jpg','.webp','.wav','.ogg'}:
            binary_hashes[path] = sha(file)
    dependencies = capture_dependencies({**text_hashes, **binary_hashes})
    manifest = {'capture_dependencies':dependencies, 'dynamic_roots':['data/','src/combat/'], 'encoded_at':datetime.now(timezone.utc).isoformat(),
        'capture_finished_at':datetime.fromtimestamp((capture/'frames.json').stat().st_mtime,timezone.utc).isoformat(),
        'capture_time_basis':'frames.json filesystem timestamp written at the end of the Godot capture',
        'engine':record['engine'],
        'source_revision':git('rev-parse','HEAD'), 'source_hashes':binary_hashes,'source_text_hashes':text_hashes,
        'text_hash_policy':'UTF8_UNIVERSAL_NEWLINES',
        'method':'Godot viewport frames after rendering; original wall-clock intervals encoded at 30 fps.',
        'limits':'Silent fixed-situation presentation captures; not campaign, balance, human fun, or PR342 validation.',
        'clips':clips}
    (out/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'clips':len(clips),'bytes':sum((ROOT/c['path']).stat().st_size for c in clips)}))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ffmpeg',required=True)
    parser.add_argument('--log',default='stderr-5.log')
    args=parser.parse_args()
    encode(args.ffmpeg,args.log)
