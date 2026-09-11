"""Export the approved 160 rows for Godot; Python is build-time only.

Keep this provider separate from the frozen v1 catalog/content identity.
"""
import argparse
import json
from pathlib import Path
from build_opponent_stage_blueprint import build, read, STAT_KEYS

ROOT = Path(__file__).resolve().parents[1]
SOURCE_REVISION = 'c95ec7e671b14cfa1e8954f1f495ba2833bbd101'
OUTPUT = ROOT / 'data/run/approved_opponent_stages_v2.json'

def generate():
    people = {person['id']: person for person in build()}
    presentation = read('docs/blueprint/OPPONENT_PRESENTATION.json')['people']
    candidates = read('data/run/vertical_slice_opponents.json')['candidates'] + read('docs/blueprint/ADDITIONAL_OPPONENTS.json')['candidates']
    result = []
    for candidate in sorted(candidates, key=lambda row: row['candidate_id']):
        candidate = dict(candidate)
        candidate['presentation'] = presentation[candidate['candidate_id']]
        rows = []
        for row in sorted(people[candidate['candidate_id']]['stages'], key=lambda row: row['stage']):
            rows.append(dict(stage=row['stage'], candidate_id=candidate['candidate_id'],
                stats=dict(zip(STAT_KEYS, row['stats'])),
                manuals=[dict(id=manual['id'], mastery=manual['mastery']) for manual in row['owned_manuals']],
                resource_caps=row['resource_caps'],
                epithet_key=f"{candidate['candidate_id']}.reputation.{min((row['stage']-1)//3,3)+1}",
                source_revision=SOURCE_REVISION))
        result.append(dict(candidate=candidate, stages=rows))
    return dict(schema_version=2, ruleset_id='ten-duel-variable-roster-v2', roster_version=1, source_revision=SOURCE_REVISION, candidates=result)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    encoded = json.dumps(generate(), ensure_ascii=False, indent=2) + '\n'
    if args.check:
        if OUTPUT.read_text(encoding='utf-8') != encoded:
            raise SystemExit('APPROVED_OPPONENT_RUNTIME_DRIFT')
        print('APPROVED_OPPONENT_RUNTIME_MATCH 16 candidates / 160 rows')
    else:
        OUTPUT.write_text(encoded, encoding='utf-8')
        print('APPROVED_OPPONENT_RUNTIME_GENERATED 16 candidates / 160 rows')
