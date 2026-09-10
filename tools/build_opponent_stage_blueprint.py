"""Planning projection only. Does not alter runtime opponent or save data."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STAT_KEYS = ['external','constitution','agility','internal_power','insight']

def read(path):
    return json.loads((ROOT/path).read_text(encoding='utf-8'))

def training_cost(masteries):
    costs = read('docs/blueprint/OPPONENT_BUDGET.json')['next_star_costs']
    if any(not isinstance(star, int) or not 3 <= star <= 10 for star in masteries):
        raise ValueError('Mastery must be an integer from 3 through 10')
    return sum(sum(costs[str(star)] for star in range(4, mastery+1)) for mastery in masteries)

def build():
    presentation=read('docs/blueprint/OPPONENT_PRESENTATION.json')
    budget=read('docs/blueprint/OPPONENT_BUDGET.json')
    profiles = {p['id']:p for p in read('data/run/vertical_slice_opponent_archetypes.json')['profiles']}
    result=[]
    candidates=read('data/run/vertical_slice_opponents.json')['candidates']+read('docs/blueprint/ADDITIONAL_OPPONENTS.json')['candidates']
    for candidate in candidates:
        detail=presentation['people'][candidate['candidate_id']]
        manual=read('data/cards/martial_manuals/'+candidate['signature_manual_id']+'.json')
        owned_ids=[candidate['signature_manual_id']]+budget['supports'][candidate['candidate_id']]
        if len(set(owned_ids)) != 3: raise ValueError('Duplicate owned manual')
        owned_data=[read('data/cards/martial_manuals/'+mid+'.json') for mid in owned_ids]
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
            stage_budget=budget['stages'][stage-1]
            total=stage_budget['stat_total']; mastery=stage_budget['masteries'][0]
            owned=[]
            for mid, data, star in zip(owned_ids,owned_data,stage_budget['masteries']):
                owned.append(dict(id=mid,name=data['manual_name'],mastery=star,
                    techniques=[v['name'] for v in data['cards'].values() if v['unlock_star']<=star],
                    upgrades=[v['name'] for v in data['overlays'].values() if v['unlock_star']<=star]))
            active=[v['name'] for v in manual['cards'].values() if v['unlock_star']<=mastery]
            upgrades=[v['name'] for v in manual['overlays'].values() if v['unlock_star']<=mastery]
            stages.append(dict(stage=stage,stats=by_total[total],stat_total=total,
                               epithet=presentation['stage_prefixes'][stage-1]+' '+detail['epithet'],
                               resource_caps=presentation['resource_caps'].copy(),
                               owned_manuals=owned,training_budget=stage_budget['training_budget'],
                               training_spent=training_cost(stage_budget['masteries']),
                               mastery=mastery,manual=manual['manual_name'],
                               techniques=active,upgrades=upgrades,ultimate_unlocked=mastery==10))
        result.append(dict(id=candidate['candidate_id'],name=candidate['working_name'],
                           identity=detail['identity'],gender=detail['gender'],
                           personality=candidate['short_personality_hook'],
                           portrait=candidate.get('portrait','output/blueprint-candidates/opponent-'+detail['art']+'.png'),
                           manual=manual['manual_name'],habit=candidate['readable_habit'],
                           counterexample=candidate['ambiguity_or_counterexample'],stages=stages))
    return result

def main():
    people=build()
    lines=['# 강호의 상대 · 10전 완성형과 단계별 등장 사양', '',
           '> 상세 수치 권장안 / 기획용 / 런타임 미연결 / 사람 밸런스 검증 전', '',
           '## 적용 범위와 기준', '',
           '기존 후보15명과 가면 검객 백무진을 합쳐16명을 다룬다. 한 회차의 비무는10전이다.',
           '각 인물은 주력 1권과 보조 2권을 보유한다. 주력의 정체성을 유지하면서 방어·거리·회복 또는 보조 공격을 조합한다.',
           '10전 능력치 합계 40을 기준으로 기존 성향 배분을 유지하여 하위 단계 수치를 정했다.',
           '표의 능력치는 무공 성장 보너스까지 포함한 최종 배분 목표이며 다시 보너스를 더하지 않는다.',
           '단계별 세 권의 성수와 수련 예산은 OPPONENT_BUDGET.json에서 생성한다. 10전은 주력10·보조7·보조5성, 추가 수련57점이다.',
           '수련 비용은 3성 취득 이후 누적 값이다. 무공 취득 기회비용은 별도이며 총 성수나 전투 위력으로 바꿔 읽지 않는다.',
           '절초 해금은 즉시 발동을 뜻하지 않는다. 기세·기력·내력·거리 등 실제 사용 조건을 계속 만족해야 한다.',
           '체력·기력·내력 상한은 현행 전투 자원 기준인 30·5·4를 전 단계에 유지한다.',
           '성장하는 다섯 능력과 소모 자원은 별개다. 검증되지 않은 능력→자원 공식을 추가하지 않는다.',
           '별호는 인물의 고유 별호 앞에 단계별 성장 수식을 붙인다. 이름·성별은 단계가 바뀌어도 유지한다.',
           '이 수치와 별호는 사용자 승인 방향의 구체 권장안이며 런타임 적용·사람 밸런스 검증과 구분한다.', '',
           '## 표 읽기', '', '외공 / 근골 / 신법 / 내공 / 심안은 순서대로 명시한다. 기술명은 실제 무공 데이터에서 읽는다.', '']
    for p in people:
        lines += [f"## {p['name']} · {p['manual']}",'',p['habit'],p['counterexample'],'',
                  '| 비무 | 외공 | 근골 | 신법 | 내공 | 심안 | 합계 | 보유 무공 / 추가 수련 | 주력 기술·절초 | 주력 강화 | 별호 | 체력/기력/내력 상한 |',
                  '|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|---|']
        for r in p['stages']:
            cells=[str(r['stage'])+'전',*[str(x) for x in r['stats']],str(r['stat_total']),
                   ' · '.join(f"{m['name']} {m['mastery']}성" for m in r['owned_manuals'])+f" / {r['training_spent']}점",' · '.join(r['techniques']),' · '.join(r['upgrades']) or '없음',r['epithet'],'30 / 5 / 4']
            lines.append('| '+' | '.join(cells)+' |')
        lines.append('')
    out=ROOT/'docs/blueprint/OPPONENT_STAGE_TABLES.md'
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_text('\n'.join(lines).rstrip()+'\n',encoding='utf-8')
    print(f'PLANNING_TABLES_GENERATED {len(people)} opponents / {sum(len(p["stages"]) for p in people)} stage rows')

if __name__=='__main__': main()
