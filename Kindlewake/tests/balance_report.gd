extends SceneTree
## Balance report: the AI plays BOTH sides, so this shows how hard each enemy group is for the starting party and how fast
## the grind pays off. It changes nothing. Run from the project folder:
##   godot --headless --path . --script res://tests/balance_report.gd           (30 battles per scenario)
##   godot --headless --path . --script res://tests/balance_report.gd -- 100    (100 battles per scenario)
## Paste the printed table back into the chat to tune HP_GAIN, enemy rewards, item and sigil values.
## (Autoloads are not used: GameData is created by hand, like in tests/run_tests.gd.)

var gd: Node


func _initialize() -> void:
    gd = load("res://scripts/core/game_data.gd").new()
    gd.reload()
    var n := 30
    var args: PackedStringArray = OS.get_cmdline_user_args()
    if args.size() > 0 and args[0].is_valid_int():
        n = clampi(int(args[0]), 5, 500)
    print("KINDLEWAKE balance report   (%d battles per scenario, AI vs AI, starting party)" % n)
    _scenario_table(n)
    _grind_curve(60)
    gd.free()
    quit(0)


func _group_label(def: Dictionary) -> String:
    var names: Array[String] = []
    for s in (def.get("units", []) as Array):
        var sd: Dictionary = s
        if str(sd.get("team", "")) == "enemy":
            names.append(str((gd.characters.get(str(sd.get("character_id", "")), {}) as Dictionary).get("name", sd.get("character_id", "?"))))
    return ", ".join(PackedStringArray(names))


func _scenario_table(n: int) -> void:
    print("")
    print("%s %s %s %s %s %s %s %s  %s" % ["Win%".lpad(5), "Turns".lpad(6), "Alive".lpad(6), "HPlost%".lpad(8), "EXP".lpad(5), "AP".lpad(4), "Gold".lpad(5), "Verdict".rpad(8), "Enemies"])
    var scenarios: Array = [gd.battle_def("battle_01")]
    for i in range(EncounterBuilder.group_count(gd.encounters)):
        scenarios.append(EncounterBuilder.build_group(gd.encounters, gd.battles, i))
    for sc in scenarios:
        _run_scenario(sc, n)


func _play(c: BattleController) -> void:
    c.begin()
    var guard := 0
    while c.result == "" and guard < 800:
        c.run_ai_turn(true)
        guard += 1


func _run_scenario(def: Dictionary, n: int) -> void:
    var party: PartyState = PartyState.new_game(gd.start, gd.characters)
    var db: Dictionary = party.battle_db(gd.as_db())
    var wins := 0
    var turns := 0
    var alive := 0
    var hp_now := 0
    var hp_max := 0
    var exp_sum := 0
    var ap_sum := 0
    var gold_sum := 0
    for i in range(n):
        var c := BattleController.new()
        c.setup(def, db, 7000 + i)
        _play(c)
        turns += c.turn_count
        for o in c.units:
            var u: BattleUnit = o
            if u.team == "player":
                hp_max += u.max_hp()
                hp_now += maxi(0, u.hp)
                if u.is_alive():
                    alive += 1
        if c.result == "victory":
            wins += 1
            var rw: Dictionary = party.battle_rewards(c.units, "victory", gd.rules_db())
            exp_sum += int(rw["total_exp"])
            ap_sum += int(rw["total_ap"])
            gold_sum += int(rw["gold"])
    var win_pct: float = 100.0 * float(wins) / float(n)
    var verdict := "fair"
    if win_pct >= 95.0:
        verdict = "easy"
    elif win_pct < 25.0:
        verdict = "brutal"
    elif win_pct < 60.0:
        verdict = "hard"
    var per_win: float = float(maxi(1, wins))
    print("%s %s %s %s %s %s %s %s  %s" % [
        ("%.0f" % win_pct).lpad(5), ("%.1f" % (float(turns) / float(n))).lpad(6),
        ("%.1f" % (float(alive) / float(n))).lpad(6), ("%.0f" % (100.0 * (1.0 - float(hp_now) / float(maxi(1, hp_max))))).lpad(8),
        ("%.0f" % (float(exp_sum) / per_win)).lpad(5), ("%.0f" % (float(ap_sum) / per_win)).lpad(4),
        ("%.0f" % (float(gold_sum) / per_win)).lpad(5), verdict.rpad(8), _group_label(def)])


## The AI plays random skirmishes with ONE persistent party and the real reward rules; shows how levels, gold and sigils grow.
func _grind_curve(battles: int) -> void:
    print("")
    print("Grind curve: %d random skirmishes with one persistent party (levels after battle N)" % battles)
    var party: PartyState = PartyState.new_game(gd.start, gd.characters)
    var rng := RandomNumberGenerator.new()
    rng.seed = 99
    var wins := 0
    for b in range(1, battles + 1):
        var def: Dictionary = EncounterBuilder.build_skirmish(gd.encounters, gd.battles, rng)
        var c := BattleController.new()
        c.setup(def, party.battle_db(gd.as_db()), 5000 + b)
        _play(c)
        party.apply_battle_result(c.units, c.result, rng, gd.rules_db())
        if c.result == "victory":
            wins += 1
        if b == 1 or b % 5 == 0:
            var parts: Array[String] = []
            for id in party.roster:
                var sh: CharacterSheet = party.sheet(id)
                parts.append("%s L%d" % [sh.display_name.get_slice(" ", 0), sh.level])
            print("  battle %2d  won %2d  gold %5d  bag sigils %d   %s" % [b, wins, party.gold, party.sigil_inv.size(), "  ".join(PackedStringArray(parts))])
    print("")
    print("Reading the numbers: Win% 60-90 is a fair fight for the starting party; EXP/AP/Gold are per VICTORY.")
    print("If levels climb too fast or too slowly, tune enemy `reward` blocks in data/characters.json and HP_GAIN in scripts/core/character_sheet.gd.")
