"""Encode only fully verified bundle frames using the existing task-local FFmpeg."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
from PIL import Image, ImageSequence

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ffmpeg', required=True, type=Path)
    args = parser.parse_args()
    report = json.loads((HERE / 'bundle-render-check.json').read_text(encoding='utf-8'))
    frames = ROOT / 'output/ink-clash-bundles/frames'
    assert not report['samples_only'] and report['frame_count'] == len(report['frames'])
    for record in report['frames']:
        source = frames / f"{record['frame']:04d}.png"
        assert hashlib.sha256(source.read_bytes()).hexdigest() == record['sha256'], source
    command = [str(args.ffmpeg.resolve()), '-hide_banner', '-loglevel', 'error', '-y', '-framerate', str(report['fps']), '-i', str(frames / '%04d.png')]
    subprocess.run(command + ['-frames:v', str(report['frame_count']), '-c:v', 'libx264', '-crf', '20', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', '-an', str(HERE / 'ink-bundles.mp4')], check=True)
    subprocess.run(command + ['-t', str(report['duration_seconds']), '-filter_complex', '[0:v]fps=10,scale=640:552:flags=lanczos,split[a][b];[a]palettegen=max_colors=96:stats_mode=full[p];[b][p]paletteuse=dither=none:diff_mode=rectangle', '-loop', '0', str(HERE / 'ink-bundles.gif')], check=True)
    with Image.open(HERE / 'ink-bundles.gif') as gif:
        distinct, duration = set(), 0
        for frame in ImageSequence.Iterator(gif):
            duration += frame.info.get('duration', 0)
            distinct.add(hashlib.sha256(frame.convert('RGB').crop((40,60,600,345)).tobytes()).hexdigest())
        check = {'size': list(gif.size), 'frames': gif.n_frames, 'loop': gif.info.get('loop'), 'duration_ms': duration, 'distinct_arena_frames': len(distinct)}
    assert check['frames'] == round(report['duration_seconds'] * 10)
    assert abs(duration - report['duration_seconds'] * 1000) < 101 and check['loop'] == 0
    assert len(distinct) > 300
    files = [{'file': f, 'sha256': hashlib.sha256((HERE / f).read_bytes()).hexdigest(), 'bytes': (HERE / f).stat().st_size} for f in ['ink-bundles.mp4', 'ink-bundles.gif', 'bundle-poster.png']]
    (HERE / 'bundle-media-check.json').write_text(json.dumps({'gif': check, 'files': files}, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps({'gif': check, 'files': files}))

if __name__ == '__main__':
    main()
