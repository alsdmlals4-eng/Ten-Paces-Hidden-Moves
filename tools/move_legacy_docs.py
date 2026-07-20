#!/usr/bin/env python3
"""Move Ten Paces topic-numbered legacy documents by meaning, never by number."""
from __future__ import annotations
import shutil
from pathlib import Path
ROOT=Path.cwd(); K='[기획서]'
MAP={
'01_GAME_DESIGN.md':'02_게임_디자인/등록_부록','02_COMBAT_RULES.md':'02_게임_디자인/등록_부록','03_CONTENT_CATALOG.md':'01_설정_내러티브/등록_부록','04_ROADMAP.md':'09_프로덕션_PM/등록_부록','05_COMBAT_POC_SPEC.md':'02_게임_디자인/등록_부록','06_STARTING_FACTION_MASTERY_DATA.md':'02_게임_디자인/등록_부록','07_COMBAT_UI_SPEC.md':'03_UX_UI_접근성/등록_부록','08_TEST_CHECKLIST.md':'08_QA/등록_부록','09_COMBAT_SYSTEM_ARCHITECTURE.md':'04_개발_엔지니어링/등록_부록','10_COMBAT_PRESENTATION_PLAN.md':'06_아트/등록_부록','11_BASE_ADOPTION_AND_LEARNING_LOG.md':'10_분석_유저리서치/등록_부록','ACTIVE_CONTEXT.md':'09_프로덕션_PM/등록_부록','BASE_RULES_VERSION.md':'[백업]/ten-paces/root-docs','DOCUMENTATION_MAP.md':'[백업]/ten-paces/root-docs','TEN_PACES_PLANNING_HANDOFF_EXTENSION.md':'[백업]/ten-paces/skills','2026-07-16-godot-12-faction-tournament-plan.md':'[백업]/ten-paces/superpowers/plans','2026-07-16-combat-poc-plan.md':'[백업]/ten-paces/plans'}
def main():
  moved=[]
  for file in sorted((ROOT/'docs').rglob('*')):
    if not file.is_file(): continue
    rel=file.relative_to(ROOT).as_posix()
    if '[백업]' in rel: dest=ROOT/K/'[백업]'/'ten-paces'/file.relative_to(ROOT/'docs'/'[백업]')
    elif '[보류]' in rel: dest=ROOT/K/'[보류]'/'ten-paces'/file.relative_to(ROOT/'docs'/'[보류]')
    else:
      folder=MAP.get(file.name,'11_통합검수/등록_부록'); dest=ROOT/K/folder/file.name
    dest.parent.mkdir(parents=True,exist_ok=True)
    if dest.exists(): raise FileExistsError(dest)
    shutil.move(str(file),str(dest)); moved.append((rel,dest.relative_to(ROOT).as_posix()))
  out=ROOT/K/'00_프로젝트_허브'/'LEGACY_DOCUMENT_MOVE_MAP.tsv'; out.parent.mkdir(parents=True,exist_ok=True); out.write_text('source\ttarget\n'+'\n'.join(f'{a}\t{b}' for a,b in moved)+'\n',encoding='utf8')
  print(f'Moved {len(moved)} documents.')
if __name__=='__main__': main()
