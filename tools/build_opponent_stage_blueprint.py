"""Planning projection only. Does not alter runtime opponent or save data."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STAT_KEYS = ['external','constitution','agility','internal_power','insight']

def read(path):
    return json.loads((ROOT/path).read_text(encoding='utf-8'))

def training_cost(masteries):
    costs = read('docs/blueprint/OPPONENT_BUDGET.json')['next_star_costs']
    if any(type(star) is not int or not 3 <= star <= 10 for star in masteries):
        raise ValueError('Mastery must be an integer from 3 through 10')
    return sum(sum(costs[str(star)] for star in range(4, mastery+1)) for mastery in masteries)

def allocate_stages(targets, budget):
    """Stable planning allocation by actual cost, not equal-star/power fiction."""
    from fractions import Fraction
    final_costs = [training_cost([m]) for m in targets]
    current = [3] * len(targets)
    result = []
    for percent in budget['stage_budget_fraction_percent']:
        available = sum(final_costs) * percent // 100
        while True:
            remaining = available - training_cost(current)
            possible = [i for i,t in enumerate(targets) if current[i] < t and budget['next_star_costs'][str(current[i]+1)] <= remaining]
            if not possible: break
            i = min(possible, key=lambda i: (Fraction(training_cost([current[i]]), final_costs[i]), i))
            current[i] += 1
        result.append((current.copy(), available))
    if current != targets: raise ValueError('Final mastery allocation failed')
    return result

def build():
    presentation=read('docs/blueprint/OPPONENT_PRESENTATION.json')
    budget=read('docs/blueprint/OPPONENT_BUDGET.json')
    profiles = {p['id']:p for p in read('data/run/vertical_slice_opponent_archetypes.json')['profiles']}
    result=[]
    candidates=read('data/run/vertical_slice_opponents.json')['candidates']+read('docs/blueprint/ADDITIONAL_OPPONENTS.json')['candidates']
    for candidate in candidates:
        detail=presentation['people'][candidate['candidate_id']]
        manual=read('data/cards/martial_manuals/'+candidate['signature_manual_id']+'.json')
        authored=budget['loadouts'][candidate['candidate_id']]
        owned_ids=[m['id'] for m in authored['manuals']]
        if len(set(owned_ids)) != len(owned_ids): raise ValueError('Duplicate owned manual')
        if owned_ids[0] != candidate['signature_manual_id']: raise ValueError('Signature identity changed')
        allocations=allocate_stages([m['final_mastery'] for m in authored['manuals']],budget)
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
            masteries, available=allocations[stage-1]
            total=budget['stat_totals'][stage-1]; mastery=masteries[0]
            owned=[]
            for mid, data, star in zip(owned_ids,owned_data,masteries):
                owned.append(dict(id=mid,name=data['manual_name'],mastery=star,
                    techniques=[v['name'] for v in data['cards'].values() if v['unlock_star']<=star],
                    upgrades=[v['name'] for v in data['overlays'].values() if v['unlock_star']<=star]))
            active=[v['name'] for v in manual['cards'].values() if v['unlock_star']<=mastery]
            upgrades=[v['name'] for v in manual['overlays'].values() if v['unlock_star']<=mastery]
            stages.append(dict(stage=stage,stats=by_total[total],stat_total=total,
                               epithet=detail['epithet_bands'][min((stage-1)//3,3)],
                               resource_caps=presentation['resource_caps'].copy(),
                               owned_manuals=owned,training_budget=available,
                               training_spent=training_cost(masteries),
                               mastery=mastery,manual=manual['manual_name'],
                               techniques=active,upgrades=upgrades,ultimate_unlocked=mastery==10))
        result.append(dict(id=candidate['candidate_id'],name=candidate['working_name'],
                           identity=detail['identity'],gender=detail['gender'],
                           tactics=authored['tactics'],role=authored['role'],
                           acquisition_count=authored['acquisition_count'],epithet_reason=detail['epithet_reason'],
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
           '각 인물은 서로 다른 2~5권 편성 권장안을 가진다. 이 범위는 이번 16명 설계 결과이지 장착 제한이 아니다.',
           '10전 능력치 합계 40을 기준으로 기존 성향 배분을 유지하여 하위 단계 수치를 정했다.',
           '표의 능력치는 무공 성장 보너스까지 포함한 최종 배분 목표이며 다시 보너스를 더하지 않는다.',
           '단계별 가변 편성과 수련 예산은 OPPONENT_BUDGET.json에서 생성한다. 두 절초 집중형과 절초 없는 다재형을 같은 위력으로 취급하지 않는다.',
           '수련 비용은 3성 취득 이후 누적 값이다. 무공 취득 기회비용은 별도이며 총 성수나 전투 위력으로 바꿔 읽지 않는다.',
           '절초 해금은 즉시 발동을 뜻하지 않는다. 기세·기력·내력·거리 등 실제 사용 조건을 계속 만족해야 한다.',
           '체력·기력·내력 상한은 현행 전투 자원 기준인 30·5·4를 전 단계에 유지한다.',
           '성장하는 다섯 능력과 소모 자원은 별개다. 검증되지 않은 능력→자원 공식을 추가하지 않는다.',
           '별호는 인물별 초출(1~3전)·명성(4~6전)·대성(7~9전)·완성(10전)의 고유 네 단계다. 이름·성별은 유지하며 전마다 억지 접두어를 붙이지 않는다.',
           '이 수치와 별호는 사용자 승인 방향의 구체 권장안이며 런타임 적용·사람 밸런스 검증과 구분한다.', '',
           '## 표 읽기', '', '외공 / 근골 / 신법 / 내공 / 심안은 순서대로 명시한다. 기술명은 실제 무공 데이터에서 읽는다.', '']
    for p in people:
        lines += [f"## {p['name']} · {p['manual']}",'',p['role'],p['epithet_reason'],p['tactics']['combination'],
                  '약점: '+p['tactics']['weakness'],'대응: '+p['tactics']['counterplay'],p['habit'],p['counterexample'],'',
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
