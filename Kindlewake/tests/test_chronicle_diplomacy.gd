extends SceneTree
const Politics = preload("res://scripts/core/chronicle_diplomacy_system.gd")
func _initialize() -> void:
 var state := Politics.initialize({"house_name":"House Test","year":1})
 assert(state.politics.houses.size() == 4)
 assert(state.politics.relations.size() == 6)
 var result := Politics.perform_action(state,"player_house","house_ashcombe","envoy")
 assert(result.ok)
 state = result.state
 assert(Politics.relation_between(state,"player_house","house_ashcombe").score == 16)
 var relation := Politics.relation_between(state,"player_house","house_ashcombe")
 relation.score = 150
 state.politics.relations["house_ashcombe|player_house"] = relation
 state = Politics.normalize(state)
 assert(Politics.relation_between(state,"player_house","house_ashcombe").score == 100)
 result = Politics.perform_action(state,"player_house","house_ashcombe","propose_alliance")
 assert(result.ok and result.relation.allied)
 state = result.state
 result = Politics.perform_action(state,"player_house","house_ashcombe","declare_feud")
 assert(result.ok and result.relation.feud and not result.relation.allied)
 state = result.state
 result = Politics.perform_action(state,"player_house","house_ashcombe","reconcile")
 assert(result.ok and not result.relation.feud)
 state = result.state
 result = Politics.advance_political_year(state)
 assert(result.ok and result.state.politics.year == 2)
 var restored := Politics.normalize(JSON.parse_string(JSON.stringify(result.state)))
 assert(restored.politics.houses.size() == 4 and restored.politics.relations.size() == 6)
 var ai_state := Politics.initialize({"house_name":"House AI","year":1})
 var pair := Politics.relation_between(ai_state,"house_ashcombe","house_dunmar")
 pair.score = -70
 ai_state.politics.relations["house_ashcombe|house_dunmar"] = pair
 var ai_result := Politics.resolve_rival_decisions(ai_state)
 assert(ai_result.ok)
 assert(Politics.relation_between(ai_result.state,"house_ashcombe","house_dunmar").feud)
 print("Chronicle diplomacy rules: PASS")
 quit()
