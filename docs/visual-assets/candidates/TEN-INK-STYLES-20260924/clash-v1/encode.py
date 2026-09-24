"""Encode the offline ink-clash frames with an existing task-local ffmpeg."""
import argparse
from pathlib import Path
import subprocess
import hashlib
import json
from PIL import Image, ImageSequence

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def run():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--ffmpeg",required=True,type=Path)
    a=p.parse_args()
    frames=ROOT/"output/ink-clash-v1/frames"
    ff=[str(a.ffmpeg.resolve()),"-hide_banner","-loglevel","error","-y","-framerate","25","-i",str(frames/"%04d.png")]
    subprocess.run(ff+["-c:v","libx264","-crf","20","-pix_fmt","yuv420p","-movflags","+faststart","-an",str(HERE/"ink-clash-v1.mp4")],check=True)
    subprocess.run(ff+["-filter_complex","[0:v]scale=960:540:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle","-loop","0",str(HERE/"ink-clash-v1.gif")],check=True)
    with Image.open(HERE/"ink-clash-v1.gif") as gif:
        distinct=set()
        duration=0
        for frame in ImageSequence.Iterator(gif):
            duration+=frame.info.get("duration",0)
            distinct.add(hashlib.sha256(frame.convert("RGB").crop((120,95,850,465)).tobytes()).hexdigest())
        check={"size":list(gif.size),"frames":gif.n_frames,"loop":gif.info.get("loop"),"duration_ms":duration,"distinct_arena_frames":len(distinct)}
    assert check["frames"]==210 and check["duration_ms"]==8400 and check["loop"]==0
    assert check["distinct_arena_frames"]>100
    assets=[]
    for name in ["ink-clash-v1.mp4","ink-clash-v1.gif","contact-41.png"]:
        file=HERE/name
        assets.append({"file":name,"sha256":hashlib.sha256(file.read_bytes()).hexdigest(),"bytes":file.stat().st_size})
    (HERE/"media-check.json").write_text(json.dumps({"gif":check,"assets":assets},indent=2)+"\n",encoding="utf-8")
    print(json.dumps(check))
if __name__=="__main__":run()
