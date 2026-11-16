extends RefCounted
## Context-sensitive tactical maps for random travel encounters. Story maps are never rewritten.
const WorldMapScript = preload("res://scripts/world/world_map.gd")
const W := 20
const H := 14

static func build_travel_map(source: Dictionary, world_map: RefCounted, cell: Vector2i, region_id: String, seed_value: int) -> Dictionary:
    var out: Dictionary = source.duplicate(true)
    var profile := _profile(world_map, cell)
    var kind := _kind(int(profile.dominant), region_id)
    var base := _ground(region_id)
    var g: Array = []
    var h: Array = []
    for y in range(H):
        var gr: Array[String] = []
        var hr: Array[String] = []
        for x in range(W):
            gr.append(base)
            hr.append("0")
        g.append(gr)
        h.append(hr)
    var v := posmod(seed_value, 3)
    match kind:
        "forest":
            _rect(g, 2,1,7,5,"f"); _rect(g,13,1,18,5,"f")
            _rect(g,1,9,5,12,"f"); _rect(g,15,9,18,12,"f")
            _rect(g,8,0,11,2,"f"); _path(g, "r", v)
            _rect(h,8,3,8,3,"1")
            out["battlefield"]="woodland_ambush"; out["weather"]="overcast"
        "hills":
            _rect(g,2,2,6,5,"h"); _rect(g,13,1,18,4,"h")
            _rect(g,3,9,7,12,"h"); _rect(g,14,9,18,12,"h")
            _rect(g,8,5,11,8,"r")
            _rect(h,2,2,6,5,"1"); _rect(h,13,1,18,4,"2")
            _rect(h,14,9,18,12,"1")
            out["battlefield"]="rolling_highlands"; out["weather"]="clear"
        "river":
            _rect(g,9,0,10,13,"~"); _rect(g,9,3+v,10,3+v,"w")
            _rect(g,9,9-v,10,9-v,"w"); _rect(g,9,6,10,7,"b")
            _rect(g,9,9,10,10,"b")
            _rect(g,3,2,5,4,"f"); _rect(g,14,9,17,11,"f")
            _rect(g,7,5,8,8,"r"); _rect(g,11,5,12,8,"r")
            out["battlefield"]="river_crossing"; out["weather"]="clear"
        "mountain":
            _rect(g,1,1,5,5,"#"); _rect(g,14,1,18,5,"#")
            _rect(g,2,9,6,12,"#"); _rect(g,14,9,18,12,"#")
            _rect(g,7,5,12,8,"h"); _rect(g,9,5,10,8,"r")
            _rect(h,1,1,5,5,"2"); _rect(h,14,1,18,5,"2")
            _rect(h,2,9,6,12,"1"); _rect(h,14,9,18,12,"2")
            out["battlefield"]="mountain_pass"; out["weather"]="windy"
        "marsh":
            _rect(g,1,2,5,4,"m"); _rect(g,13,1,18,4,"m")
            _rect(g,3,9,7,12,"m"); _rect(g,13,9,18,12,"m")
            _rect(g,8,0,11,13,"r"); _rect(g,5,6,7,7,"~")
            _rect(g,12,6,14,7,"~")
            out["battlefield"]="sallow_marsh"; out["weather"]="mist"
        "snow":
            _rect(g,2,1,6,4,"s"); _rect(g,13,1,18,5,"s")
            _rect(g,1,9,5,12,"s"); _rect(g,15,9,18,12,"s")
            _rect(g,8,0,11,13,"r"); _rect(g,5,5,6,7,"#")
            _rect(g,14,6,15,8,"#")
            out["battlefield"]="frostfield"; out["weather"]="snow"
        "ash":
            _rect(g,1,2,5,5,"a"); _rect(g,14,1,18,4,"a")
            _rect(g,2,9,6,12,"a"); _rect(g,14,9,18,12,"a")
            _rect(g,8,0,11,13,"r"); _rect(g,5,6,6,8,"#")
            _rect(g,13,6,14,8,"#")
            out["battlefield"]="ashen_wastes"; out["weather"]="ashfall"
        "ruins":
            _rect(g,2,2,4,4,"u"); _rect(g,15,1,18,3,"u")
            _rect(g,2,9,5,11,"u"); _rect(g,15,9,18,12,"u")
            _rect(g,8,0,11,13,"r"); _rect(g,9,5,10,8,"u")
            out["battlefield"]="overgrown_ruins"; out["weather"]="overcast"
        _:
            _rect(g,2,2,5,4,"f"); _rect(g,14,8,17,10,"h")
            _path(g,"r",v); out["battlefield"]="open_grassland"
            out["weather"]="clear"
    var legend := {".":base,"f":"forest","r":"road","h":"hill","w":"ford","~":"deep_water","b":"bridge","#":"rock","m":"marsh","s":"snow","a":"ash","u":"ruins"}
    var rows: Array[String]=[]; var heights: Array[String]=[]
    for y in range(H):
        rows.append("".join(PackedStringArray(g[y]))); heights.append("".join(PackedStringArray(h[y])))
    out["legend"]=legend; out["terrain"]=rows; out["heights"]=heights
    out["battlefield_region"]=region_id
    out["battlefield_tile"]=str(profile.dominant_name)
    out["battlefield_variant"]=v
    out["title"]=str(out.get("title","Travel Skirmish"))+" — "+str(out["battlefield"]).replace("_"," ").capitalize()
    out["briefing"]=str(out.get("briefing",""))+"\nGround: "+str(profile.dominant_name)+" in "+region_id.replace("_"," ").capitalize()+". Terrain, cover, elevation and routes reflect the encounter site."
    return out

static func _profile(m: RefCounted, centre: Vector2i) -> Dictionary:
    var counts := {}
    for y in range(-3,4):
        for x in range(-3,4):
            var t: int=m.terrain_at(centre+Vector2i(x,y))
            counts[t]=int(counts.get(t,0))+1
    var dominant: int=m.terrain_at(centre)
    for k in counts:
        if int(counts[k])>int(counts.get(dominant,0)): dominant=int(k)
    if int(counts.get(WorldMapScript.BRIDGE,0))>0 or int(counts.get(WorldMapScript.FORD,0))>=3 or int(counts.get(WorldMapScript.WATER,0))>=6: dominant=WorldMapScript.FORD
    elif int(counts.get(WorldMapScript.MOUNTAIN,0))>=5: dominant=WorldMapScript.MOUNTAIN
    return {"dominant":dominant,"dominant_name":WorldMapScript.NAMES[dominant]}

static func _kind(t: int, region_id: String) -> String:
    var r:=region_id.to_lower()
    if r.contains("frost") or r.contains("snow") or r.contains("northstar") or r.contains("ice"): return "snow"
    if r.contains("ash") or r.contains("cinder") or r.contains("volcan") or r.contains("ember"): return "ash"
    if r.contains("ruin") or r.contains("aster"): return "ruins"
    if r.contains("sallow"): return "marsh"
    if r.contains("veyrwood") or r.contains("briar"): return "forest"
    match t:
        WorldMapScript.FOREST: return "forest"
        WorldMapScript.HILL: return "hills"
        WorldMapScript.FORD, WorldMapScript.WATER, WorldMapScript.BRIDGE: return "river"
        WorldMapScript.MOUNTAIN: return "mountain"
        _: return "road" if t==WorldMapScript.ROAD else "grass"

static func _ground(region_id: String) -> String:
    var r:=region_id.to_lower()
    if r.contains("frost") or r.contains("snow") or r.contains("northstar") or r.contains("ice"): return "s"
    if r.contains("ash") or r.contains("cinder") or r.contains("volcan") or r.contains("ember"): return "a"
    if r.contains("sallow"): return "m"
    if r.contains("ruin") or r.contains("aster"): return "u"
    return "."

static func _rect(g: Array, x0: int,y0: int,x1: int,y1: int,value: String) -> void:
    for y in range(maxi(0,y0),mini(H,y1+1)):
        for x in range(maxi(0,x0),mini(W,x1+1)): g[y][x]=value

static func _path(g: Array, value: String, variant: int) -> void:
    var x:=9+variant
    for y in range(H):
        _rect(g,x,y,x+1,y,value)
        if y%4==1: x=clampi(x+(1 if variant%2==0 else -1),7,12)
