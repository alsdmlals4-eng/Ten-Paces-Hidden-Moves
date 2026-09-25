extends SceneTree
var checks:=0
var failures:=0

func _initialize() -> void:call_deferred("verify")

func verify() -> void:
    var view=load("res://src/ui/frame/frame_combat_view.gd").new()
    root.add_child(view)
    await process_frame
    var actor:Dictionary={"health":[30,30],"stamina":[5,5],"internal":[4,4],"tile":4}
    var before:Dictionary={"player":actor,"enemy":actor.duplicate(true),"frame":{"time_tick":0,"carry":{"player":{}}}}
    before.enemy.tile=6
    var card:Dictionary={"id":"basic_quick_attack","name":"속공","category":"attack","source":"basic","frame_timing":{"startup":3,"active":2,"recovery":5,"total":10}}
    var known:Array=[{"uid":"enemy:10:basic_quick_attack","card_id":"basic_quick_attack","name":"속공","start_tick":10,"active_tick":13,"end_tick":20,"frame_timing":card.frame_timing}]
    var result:Dictionary={"state":{"frame":{"time_tick":100}},"events":[]}
    view.set_data(before,[card],[],known)
    view.play(result,before,[],known)
    view._replay()
    check(view.movie_timeline.public_enemy==known,"replay preserves knowledge at the committed boundary")
    var original:Dictionary=view.stage.cue.duplicate(true)
    view._show_event({"type":"action_complete","actor":"player","actions":[{"actor":"player","card_id":"basic_quick_attack","outcome":"complete"}]})
    check(view.stage.cue==original,"recovery completion does not create a second attack animation")
    check(before.player.health==[30,30],"replay and completion display never change outcome resources")
    view.queue_free()
    print("FRAME_PLAYBACK_VIEW checks=%d failures=%d" % [checks,failures])
    quit(0 if failures==0 else 1)

func check(value:bool,label:String) -> void:
    checks+=1
    if not value:failures+=1;printerr("FAIL: ",label)
