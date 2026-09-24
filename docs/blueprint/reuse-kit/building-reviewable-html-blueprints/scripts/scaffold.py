"""Create an isolated, dependency-free HTML review UI example. Never overwrite."""
import argparse
from pathlib import Path
import re
import json

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--output", required=True, type=Path)
    p.add_argument("--project-id", required=True)
    p.add_argument("--project-name", required=True)
    args=p.parse_args()
    if not re.fullmatch(r"[a-z0-9][a-z0-9-]{1,63}", args.project_id):
        p.error("project-id must contain 2-64 lowercase letters, digits or hyphens")
    dest=args.output.resolve()
    if dest.exists() and (not dest.is_dir() or any(dest.iterdir())):
        p.error("output must be an empty directory; existing files are protected")
    dest.mkdir(parents=True,exist_ok=True)
    assets=Path(__file__).resolve().parents[1]/"assets"
    page=(assets/"review-board.html").read_text(encoding="utf-8")
    config=json.dumps({"id":args.project_id,"name":args.project_name},ensure_ascii=False).replace("<","\\u003c").replace(">","\\u003e").replace("&","\\u0026")
    (dest/"index.html").write_bytes(page.replace("__PROJECT_CONFIG__",config).encode("utf-8"))
    print(dest/"index.html")
if __name__=="__main__":
    main()
