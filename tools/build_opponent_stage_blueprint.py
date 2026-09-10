"""Planning projection only. Does not alter runtime opponent or save data."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOTALS = [20,22,24,26,28,30,32,34,37,40]
MASTERY = [3,3,5,5,7,7,9,9,10,10]
STAT_KEYS = ['external','constitution','agility','internal_power','insight']

def read(path):
    return json.loads((ROOT/path).read_text(encoding='utf-8'))

def build():
    presentation=read('docs/blueprint/OPPONENT_PRESENTATION.json')
    profiles = {p['id']:p for p in read('data/run/vertical_slice_opponent_archetypes.json')['profiles']}
    result=[]
    for candidate in read('data/run/vertical_slice_opponents.json')['candidates']:
        detail=presentation['people'][candidate['candidate_id']]
        manual=read('data/cards/martial_manuals/'+candidate['signature_manual_id']+'.json')
        weights=profiles[candidate['runtime_archetype_id']]['stat_weights']
        # Highest-stage blueprint is fixed first; lower stages remove points
        # from the most overrepresented stat relative to the existing archetype.
        stats=[weights[k]*2 for k in STAT_KEYS]
        by_total={40:stats.copy()}
        for total in range(39,19,-1):
            i=max(range(5),key=lambda j:(stats[j]/weights[STAT_KEYS[j]],stats[j],-j))
            stats[i]-=1
            by_total[total]=stats.copy()
        stages=[]
        for stage in range(10,0,-1):
            total=TOTALS[stage-1]; mastery=MASTERY[stage-1]
            active=[v['name'] for v in manual['cards'].values() if v['unlock_star']<=mastery]
            upgrades=[v['name'] for v in manual['overlays'].values() if v['unlock_star']<=mastery]
            stages.append(dict(stage=stage,stats=by_total[total],stat_total=total,
                               epithet=presentation['stage_prefixes'][stage-1]+' '+detail['epithet'],
                               resource_caps=presentation['resource_caps'].copy(),
                               mastery=mastery,manual=manual['manual_name'],
                               techniques=active,upgrades=upgrades,ultimate_unlocked=mastery==10))
        result.append(dict(id=candidate['candidate_id'],name=candidate['working_name'],
                           identity=detail['identity'],gender=detail['gender'],
                           personality=candidate['short_personality_hook'],
                           portrait='output/blueprint-candidates/opponent-'+detail['art']+'.png',
                           manual=manual['manual_name'],habit=candidate['readable_habit'],
                           counterexample=candidate['ambiguity_or_counterexample'],stages=stages))
    return result

def main():
    people=build()
    lines=['# 강호의 상대 · 10전 완성형과 단계별 등장 사양', '',
           '> 상세 수치 권장안 / 기획용 / 런타임 미연결 / 사람 밸런스 검증 전', '',
           '## 적용 범위와 기준', '',
           '기존 후보 15명을 누락하지 않고 모두 다룬다. 한 회차의 비무는 10전이다. ',
           '각 인물은 현재 연결된 주력 무공 1권을 유지하며, 새 보조 무공을 임의 혼합하지 않는다.',
           '10전 능력치 합계 40을 기준으로 기존 성향 배분을 유지하여 하위 단계 수치를 정했다.',
           '표의 능력치는 무공 성장 보너스까지 포함한 최종 배분 목표이며 다시 보너스를 더하지 않는다.',
           '성수는 1전부터 3·3·5·5·7·7·9·9·10·10성이다. 짝수 전은 능력치로 성장하고,',
           '3·5·7·9전은 강화 또는 새 기술이 열린다. 9전은 절초를 미리 경험하고 10전에서 최고 능력으로 만난다.',
           '절초 해금은 즉시 발동을 뜻하지 않는다. 기세·기력·내력·거리 등 실제 사용 조건을 계속 만족해야 한다.',
           '체력·기력·내력 상한은 현행 전투 자원 기준인 30·5·4를 전 단계에 유지한다.',
           '성장하는 다섯 능력과 소모 자원은 별개다. 검증되지 않은 능력→자원 공식을 추가하지 않는다.',
           '별호는 인물의 고유 별호 앞에 단계별 성장 수식을 붙인다. 이름·성별은 단계가 바뀌어도 유지한다.',
           '이 수치와 별호는 사용자 승인 방향의 구체 권장안이며 런타임 적용·사람 밸런스 검증과 구분한다.', '',
           '## 표 읽기', '', '외공 / 근골 / 신법 / 내공 / 심안은 순서대로 명시한다. 기술명은 실제 무공 데이터에서 읽는다.', '']
    for p in people:
        lines += [f"## {p['name']} · {p['manual']}",'',p['habit'],p['counterexample'],'',
                  '| 비무 | 외공 | 근골 | 신법 | 내공 | 심안 | 합계 | 보유 무공 | 사용 기술·절초 | 적용 강화 | 별호 | 체력/기력/내력 상한 |',
                  '|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|---|']
        for r in p['stages']:
            cells=[str(r['stage'])+'전',*[str(x) for x in r['stats']],str(r['stat_total']),
                   f"{r['manual']} {r['mastery']}성",' · '.join(r['techniques']),' · '.join(r['upgrades']) or '없음',r['epithet'],'30 / 5 / 4']
            lines.append('| '+' | '.join(cells)+' |')
        lines.append('')
    out=ROOT/'docs/blueprint/OPPONENT_STAGE_TABLES.md'
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print(f'PLANNING_TABLES_GENERATED {len(people)} opponents / {sum(len(p["stages"]) for p in people)} stage rows')

if __name__=='__main__': main()
