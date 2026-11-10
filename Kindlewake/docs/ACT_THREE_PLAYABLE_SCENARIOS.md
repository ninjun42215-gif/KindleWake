# Act III — The River Campaign: Playable Implementation

## Scope
Adds the first playable Act III arc after Act II completion. All progression and consequences use the existing offline campaign world_flags; no hosted services or online dependency are introduced.

## Scenarios
1. **Three Bridges (Thornmere):** operation planning followed by a dedicated tactical battle against River Marshal Edrik Vane. The battle objective is to defeat the commander; narrative flags record the ford secured, evacuation bridge held and storehouse status. Bram anchors the bridge and Sela provides reconnaissance.
2. **The Banner in the Reeds (Elderbough):** a truce-first encounter with a deserter sheltering civilians beneath a false hostile banner. The player may protect deserters and obtain testimony, expose the deception, or use the banner as leverage. Bram's confession about an abandoned village is recorded without forced absolution.
3. **The Price of a Crossing (Sallow Crossing):** allocate the first protected convoy to displaced families, wounded soldiers or stores. Each branch records a distinct humanitarian/logistical result and changes the regional-control descriptor.

## Consequences
- act3_ford_secured, act3_evacuation_bridge_held, act3_storehouse_saved
- act3_banner_decision, act3_civilians_sheltered, act3_deserter_testimony
- act3_crossing_allocation, act3_refugees_evacuated, act3_wounded_evacuated, act3_stores_protected
- act3_regional_control_river_road distinguishes contested-secure, shared corridor and company-administered outcomes.
- chapter_3_complete unlocks only after the three-scenario sequence resolves.

## Validation
JSON syntax and map placement can be structurally checked. Godot parser, headless suite and in-engine playtesting remain required; no runtime-tested claim is made here.
