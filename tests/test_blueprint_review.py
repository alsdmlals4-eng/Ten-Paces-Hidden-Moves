import json, tempfile, unittest, sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/"tools"))

class ReviewStoreTests(unittest.TestCase):
    def store(self, root):
        from blueprint_review_store import ReviewStore
        return ReviewStore(root)
    def test_roundtrip_revision_conflict_and_no_arbitrary_paths(self):
        from blueprint_review_store import Conflict
        with tempfile.TemporaryDirectory() as tmp:
            store=self.store(Path(tmp)); self.assertEqual(store.read()["revision"],0)
            result=store.save({"revision":0,"item_id":"screen:menu","status":"changes","comment":"배경 대비를 낮춰 주세요 <script>x</script>","fingerprint":"abc","source_revision":"head"})
            self.assertEqual(result["revision"],1)
            self.assertEqual(self.store(Path(tmp)).read()["items"]["screen:menu"][-1]["status"],"changes")
            with self.assertRaises(Conflict): store.save({"revision":0,"item_id":"screen:menu","status":"checked","comment":"","fingerprint":"abc","source_revision":"head"})
            with self.assertRaises(ValueError): store.save({"revision":1,"item_id":"../outside","status":"checked","comment":"","fingerprint":"abc","source_revision":"head"})
    def test_history_corruption_and_import_are_lossless(self):
        with tempfile.TemporaryDirectory() as tmp:
            store=self.store(Path(tmp))
            for i,s in enumerate(["changes","checked"]): store.save({"revision":i,"item_id":"asset:a","status":s,"comment":"수정 "+str(i),"fingerprint":"abc","source_revision":"head"})
            data=store.read();self.assertEqual(len(data["items"]["asset:a"]),2)
            store.import_document(data,2); self.assertEqual(len(store.read()["items"]["asset:a"]),2)
            store.path.write_text("broken",encoding="utf-8")
            with self.assertRaises(ValueError): store.read()
            self.assertTrue(store.path.with_suffix(".json.bak").exists())
    def test_rejects_wrong_project_oversize_and_unknown_status(self):
        with tempfile.TemporaryDirectory() as tmp:
            store=self.store(Path(tmp))
            for change in [{"status":"approved"},{"comment":"x"*10001},{"revision":True}]:
                body={"revision":0,"item_id":"giyun:a","status":"pending","comment":"","fingerprint":"f","source_revision":"head",**change}
                with self.assertRaises(ValueError):store.save(body)
            with self.assertRaises(ValueError):store.import_document({"schema_version":1,"project":"other","revision":0,"items":{}},0)

class AssetAuditTests(unittest.TestCase):
    def test_absence_of_literal_reference_never_means_safe_delete(self):
        from html_blueprint_audit import classify
        row=classify({"approval":"APPROVAL_UNVERIFIED","scope":"MAIN_SOURCE","active":False},[],[],[],[])
        self.assertFalse(row["safe_to_move"])
        self.assertIn("unverified",row["flags"])
        self.assertIn("unreferenced",row["flags"])
    def test_approved_original_and_candidate_usage_are_protected(self):
        from html_blueprint_audit import classify
        for a in [{"approval":"USER_APPROVED","scope":"MAIN_SOURCE"},{"approval":"APPROVAL_UNVERIFIED","scope":"PR342_CANDIDATE"}]:
            row=classify(a,[],[],[],[]);self.assertFalse(row["safe_to_move"]);self.assertIn("retain",row["flags"])
    def test_unapproved_runtime_and_replacement_are_separate_flags(self):
        from html_blueprint_audit import classify
        r=classify({"approval":"APPROVAL_UNVERIFIED","scope":"MAIN_SOURCE"},["src/x.gd"],[],["new"],[])
        self.assertIn("approval_gap",r["flags"]);self.assertIn("replaced",r["flags"]);self.assertFalse(r["safe_to_move"])

class ReviewHTTPTests(unittest.TestCase):
    def test_scoped_json_writes_origin_token_and_conflict(self):
        import http.client,threading
        from unittest.mock import patch
        import serve_html_blueprint as preview
        from blueprint_review_store import ReviewStore
        with tempfile.TemporaryDirectory() as tmp:
            with patch.object(preview,'ROOT',Path(tmp)):
                server=preview.create_server({},'secret',review_store=ReviewStore(Path(tmp)/'private'))
                thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start()
                def request(method,path,body=None,origin=True):
                    c=http.client.HTTPConnection('127.0.0.1',server.server_port)
                    headers={'Content-Type':'application/json','X-Blueprint-Review':'1'}
                    if origin:headers['Origin']='http://127.0.0.1:'+str(server.server_port)
                    c.request(method,path,json.dumps(body) if body else None,headers);r=c.getresponse();result=(r.status,r.read());c.close();return result
                try:
                    self.assertEqual(request('GET','/p/secret/_review')[0],200)
                    self.assertEqual(request('GET','/p/secret/_review/export')[0],200)
                    body={'revision':0,'item_id':'screen:menu','status':'changes','comment':'대비 수정','fingerprint':'f','source_revision':'head'}
                    self.assertEqual(request('POST','/p/wrong/_review',body)[0],405)
                    self.assertEqual(request('POST','/p/secret/_review',body,False)[0],403)
                    self.assertEqual(request('POST','/p/secret/_review',body)[0],200)
                    self.assertEqual(request('POST','/p/secret/_review',body)[0],409)
                    self.assertEqual(request('POST','/p/secret/src/game.gd',body)[0],405)
                finally:server.shutdown();server.server_close();thread.join()


class GroupingTests(unittest.TestCase):
    def test_same_character_variants_and_screen_assets_group_together(self):
        from html_blueprint_audit import group_assets
        assets=[{'path':p,'details':{}} for p in [
            'assets/portraits/dogyeom_status_portrait_01_v1.png',
            'assets/characters/motion/dogyeom_attack.png',
            'docs/visual-assets/approved/DOGYEOM_BATTLER.png',
            'assets/ui/logo/journey_title_reference_v1.png',
            'docs/runtime-captures/x/briefing-selected-fixed.png',
            'assets/backgrounds/jianghu_rest_inn_v1.png',
            'assets/characters/motion/enemy_reactions_candidate_v2.png']]
        group_assets(assets,[{'id':'slot1_dogyeom','name':'도겸'}],[])
        self.assertEqual(len({a['group']['id'] for a in assets[:3]}),1)
        self.assertEqual(assets[3]['group']['id'],'screen:menu')
        self.assertEqual(assets[4]['group']['id'],'screen:brief')
        self.assertEqual(assets[5]['group']['id'],'screen:route')
        self.assertEqual(assets[6]['group']['id'],'character:shared-enemy')
        self.assertEqual(assets[1]['group']['role'],'모션·포즈')
    def test_new_tracked_image_invalidates_inventory(self):
        import subprocess
        from html_blueprint_audit import inventory_digest
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);subprocess.run(['git','init','-q',tmp],check=True)
            first=inventory_digest(root)
            (root/'new.png').write_bytes(b'example')
            subprocess.run(['git','add','new.png'],cwd=root,check=True)
            self.assertNotEqual(first,inventory_digest(root))
    def test_pretty_printed_size_is_enforced_before_any_write(self):
        from unittest.mock import patch
        from blueprint_review_store import ReviewStore
        with tempfile.TemporaryDirectory() as tmp:
            store=ReviewStore(tmp)
            with patch('blueprint_review_store.LIMIT',400):
                with self.assertRaises(ValueError):
                    store.save({'revision':0,'item_id':'screen:menu','status':'changes','comment':'x'*80,'fingerprint':'f','source_revision':'head'})
            self.assertFalse(store.path.exists())


class CandidateReferenceTests(unittest.TestCase):
    def test_candidate_only_document_is_counted_as_its_own_revision(self):
        import subprocess
        from html_blueprint_audit import build
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);subprocess.run(['git','init','-q',tmp],check=True)
            for folder in ['src','scenes','data']:
                (root/folder).mkdir();(root/folder/'placeholder.json').write_text('{}',encoding='utf-8')
            (root/'docs').mkdir();(root/'docs/candidate.json').write_text('{"path":"assets/candidate.png"}',encoding='utf-8')
            subprocess.run(['git','add','.'],cwd=root,check=True)
            subprocess.run(['git','-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','-qm','fixture'],cwd=root,check=True)
            rev=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
            asset={'id':'candidate','path':'assets/candidate.png','scope':'PR342_CANDIDATE','revision':rev,'consumers':[],'sha256':'fixture','details':{},'approval':'APPROVAL_UNVERIFIED'}
            build(root,[asset])
            self.assertEqual(asset['audit']['document_references'],['docs/candidate.json'])
            self.assertNotIn('unreferenced',asset['audit']['flags'])
            self.assertEqual(asset['audit']['runtime_references'],[])
