#!/usr/bin/env python3
"""Static checker for the Kindlewake GDScript code base. It needs NO Godot and NO packages.

Run from the project folder:   python3 -I tools/gd_static_check.py
Exit code 0 = no ERROR found (warnings are listed but do not fail).

What it checks (it is a linter, NOT a replacement for running the game in Godot):
  * indentation (spaces only, multiples of 4), balanced brackets, a leading class_name/extends
  * duplicate members; local variables that redeclare a name of an enclosing scope (a Godot parse error)
  * every project class: calls to missing methods / wrong argument count / missing members / missing signals,
    following typed variables, typed members, return types and `Class.new()` chains
  * identifiers that are not declared anywhere (typos)
  * `:=` declarations whose right side is probably an untyped Variant (Godot refuses to infer those)
  * signal .connect() handlers that do not exist; preload()/load() and autoload paths that do not exist
  * every data/*.json file: syntax and cross-references (items, weapons, sigils, skills, characters, battles)
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
errors = []
warnings = []


def err(path, line, msg):
    errors.append("ERROR %s:%d  %s" % (path, line, msg))


def warn(path, line, msg):
    warnings.append("warn  %s:%d  %s" % (path, line, msg))


# ------------------------------------------------------------------ lexing helpers

def blank_line(line, in_str):
    """Blanks string contents and strips a trailing comment. Returns (text, still_in_triple_string)."""
    out = []
    i = 0
    n = len(line)
    quote = None
    while i < n:
        ch = line[i]
        if quote:
            if ch == "\\" and i + 1 < n:
                out.append("~~")
                i += 2
                continue
            if ch == quote:
                quote = None
                out.append(ch)
            else:
                out.append("~")
            i += 1
            continue
        if ch == "#":
            break
        if ch in "\"'":
            quote = ch
            out.append(ch)
            i += 1
            continue
        out.append(ch)
        i += 1
    return "".join(out), False


def logical_lines(raw_lines, path):
    """Joins continuation lines (open brackets). Returns [(lineno, indent, text, raw_text)]."""
    res = []
    depth = 0
    cur = None
    for idx, raw in enumerate(raw_lines, 1):
        if "\t" in raw[: len(raw) - len(raw.lstrip())]:
            err(path, idx, "tab in indentation (use 4 spaces)")
        text, _ = blank_line(raw.rstrip("\n"), False)
        stripped = text.strip()
        if depth == 0:
            if not stripped:
                continue
            indent = len(text) - len(text.lstrip(" "))
            cur = [idx, indent, stripped, raw.strip()]
        else:
            if stripped:
                cur[2] += " " + stripped
                cur[3] += " " + raw.strip()
        for ch in text:
            if ch in "([{":
                depth += 1
            elif ch in ")]}":
                depth -= 1
        if depth < 0:
            err(path, idx, "unbalanced closing bracket")
            depth = 0
        if depth == 0 and cur is not None:
            res.append(tuple(cur))
            cur = None
    if depth != 0:
        err(path, len(raw_lines), "unbalanced brackets at end of file")
    return res


def split_args(s):
    """Splits a call's argument text at top-level commas."""
    args, depth, cur = [], 0, []
    for ch in s:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == "," and depth == 0:
            args.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)
    last = "".join(cur).strip()
    if last or args:
        args.append(last)
    return [a for a in args if a != ""]


# ------------------------------------------------------------------ class model

class FuncInfo:
    def __init__(self, name, params, ret, static, line):
        self.name = name
        self.params = params          # [(name, type or None, has_default)]
        self.ret = ret
        self.static = static
        self.line = line

    def arity(self):
        lo = sum(1 for p in self.params if not p[2])
        return lo, len(self.params)


class ClassInfo:
    def __init__(self, name, path, base):
        self.name = name
        self.path = path
        self.base = base
        self.funcs = {}
        self.vars = {}        # name -> type or None
        self.consts = {}
        self.signals = {}     # name -> nparams
        self.enums = {}       # enum name -> [members]
        self.enum_values = set()


OBJ_MEMBERS = {
    "new", "free", "get", "set", "call", "callv", "connect", "disconnect", "emit_signal", "has_method", "has_signal",
    "is_class", "get_class", "to_string", "get_script", "set_script", "notification", "is_connected",
    "get_instance_id", "queue_free", "init_ref", "reference", "unreference", "get_reference_count", "call_deferred",
    "set_meta", "get_meta", "has_meta", "is_queued_for_deletion", "get_signal_connection_list",
}

NODE_MEMBERS = {
    "add_child", "remove_child", "get_tree", "get_children", "get_child", "get_child_count", "queue_redraw",
    "get_canvas_transform", "get_viewport", "get_viewport_rect", "set_process", "set_process_input", "name", "visible",
    "position", "global_position", "modulate", "scale", "rotation", "draw_line", "draw_rect", "draw_circle",
    "draw_colored_polygon", "draw_polyline", "draw_arc", "draw_string", "draw_polygon", "draw_texture", "get_node",
    "get_parent", "is_inside_tree", "add_to_group", "set_anchors_and_offsets_preset", "root", "quit", "create_timer",
    "create_tween", "make_current", "grow_horizontal", "grow_vertical", "custom_minimum_size", "mouse_filter",
    "autowrap_mode", "text", "disabled", "toggle_mode", "set_pressed_no_signal", "pressed", "toggled", "tree_entered",
    "size", "set_deferred", "get_window", "process_mode", "owner", "z_index", "hide", "show", "move_child",
    "set_anchor", "set_offset", "get_global_mouse_position", "get_local_mouse_position", "is_node_ready", "layout_mode",
    "button_pressed", "alignment", "queue_sort", "set_size", "get_minimum_size", "get_rect", "focus_mode",
    "horizontal_alignment", "vertical_alignment", "size_flags_horizontal", "size_flags_vertical", "clip_text",
    "scroll_horizontal", "scroll_vertical", "set_v_scroll", "get_v_scroll_bar", "move_to_front", "grab_focus",
    "add_theme_font_size_override", "add_theme_constant_override", "add_theme_stylebox_override", "add_theme_color_override",
    "set_tooltip_text", "ensure_control_visible", "theme", "flat", "icon", "min_value", "max_value", "value",
    "step", "show_percentage", "fill_mode", "anchor_left", "anchor_right", "anchor_top", "anchor_bottom",
    "offset_left", "offset_right", "offset_top", "offset_bottom", "color", "texture", "tooltip_text", "clip_contents",
    "get_theme_default_font", "get_theme_font_size", "add_separator", "scroll_deadzone", "follow_focus",
    "horizontal_scroll_mode", "vertical_scroll_mode", "accept_event", "set_scroll", "update_minimum_size", "text_overrun_behavior",
}

SCENETREE_MEMBERS = {"quit", "root", "create_timer", "get_root", "current_scene", "change_scene_to_file", "paused"}

KEYWORDS = {
    "if", "elif", "else", "for", "while", "match", "break", "continue", "pass", "return", "class", "class_name", "extends",
    "is", "in", "as", "self", "signal", "func", "static", "const", "enum", "var", "await", "not", "and", "or",
    "true", "false", "null", "void", "super", "yield", "assert", "preload", "breakpoint", "when", "setget",
}

BUILTIN_LOWER = {
    "int", "str", "float", "bool", "range", "print", "push_error", "push_warning", "printerr", "mini", "maxi", "minf",
    "maxf", "clampi", "clampf", "clamp", "absi", "absf", "abs", "roundi", "round", "ceil", "floor", "sqrt", "cos", "sin",
    "min", "max", "lerp", "randi", "randf", "randomize", "is_equal_approx", "typeof", "load", "len", "sign", "signi",
    "signf", "snappedf", "snapped", "pow", "log", "exp", "fmod", "fposmod", "posmod", "lerpf", "inverse_lerp", "remap",
    "deg_to_rad", "rad_to_deg", "is_instance_valid", "var_to_str", "str_to_var", "hash", "move_toward", "floori",
    "ceili", "print_rich", "randf_range", "randi_range", "atan2", "tan", "acos", "asin", "atan", "wrapi", "wrapf",
    "is_zero_approx", "type_string", "char", "ord", "error_string",
}

ENGINE_UPPER = {
    "Vector2", "Vector2i", "Vector3", "Rect2", "Rect2i", "Color", "Callable", "Signal", "Dictionary", "Array", "String",
    "StringName", "Object", "Node", "Node2D", "Control", "Button", "Label", "HBoxContainer", "VBoxContainer",
    "PanelContainer", "CanvasLayer", "Camera2D", "StyleBoxFlat", "TextServer", "ThemeDB", "HashingContext", "FileAccess",
    "DirAccess", "ConfigFile", "JSON", "Time", "RandomNumberGenerator", "InputEvent", "InputEventScreenTouch",
    "InputEventScreenDrag", "InputEventMouseButton", "InputEventMouseMotion", "SceneTree", "RefCounted", "OK", "PI",
    "TAU", "INF", "NAN", "PackedVector2Array", "PackedStringArray", "PackedByteArray", "PackedInt32Array", "Variant",
    "Engine", "OS", "DisplayServer", "ResourceLoader", "ImageTexture", "Camera2D", "Input", "ProjectSettings", "ScrollContainer", "GridContainer", "MarginContainer", "CenterContainer",
    "ColorRect", "TextureRect", "ProgressBar", "TabContainer", "HSeparator", "VSeparator", "RichTextLabel", "Panel",
    "CheckButton", "OptionButton", "LineEdit", "Timer", "Tween", "Resource", "Mode", "Transform2D", "Basis", "Image",
    "AudioStreamPlayer", "Window", "Viewport", "Font", "PackedColorArray", "PackedFloat32Array", "TextureButton",
    "StyleBox", "Theme", "BoxContainer", "Container", "FlowContainer", "HFlowContainer", "VFlowContainer", "SplitContainer",
    "HSplitContainer", "VSplitContainer", "SubViewport", "TextEdit", "Range", "Slider", "HSlider", "VSlider",
    "AspectRatioContainer", "ButtonGroup", "LinkButton", "MenuButton", "PopupPanel", "Popup", "ConfirmationDialog",
    "AcceptDialog", "Texture2D", "Sprite2D", "Line2D", "Polygon2D", "Area2D", "Marker2D", "CanvasItem", "SystemFont",
}


def parse_func_header(text, line):
    m = re.match(r"(static\s+)?func\s+(\w+)\s*\((.*)\)\s*(?:->\s*([\w\[\]\. ]+?))?\s*:\s*$", text)
    if not m:
        return None
    static = bool(m.group(1))
    name = m.group(2)
    params = []
    for a in split_args(m.group(3)):
        pm = re.match(r"(\w+)\s*(?::\s*([\w\[\]\.]+))?\s*(:=|=)?\s*(.*)$", a)
        if not pm:
            continue
        ptype = pm.group(2)
        has_default = pm.group(3) is not None
        if pm.group(3) == ":=":
            ptype = None
        params.append((pm.group(1), ptype, has_default))
    ret = m.group(4).strip() if m.group(4) else None
    return FuncInfo(name, params, ret, static, line)


def load_files():
    files = {}
    for sub in ("scripts", "tests"):
        for p in sorted((ROOT / sub).rglob("*.gd")):
            rel = p.relative_to(ROOT).as_posix()
            files[rel] = logical_lines(p.read_text(encoding="utf-8").split("\n"), rel)
    return files


def build_classes(files, autoloads):
    classes = {}
    by_path = {}
    for rel, lines in files.items():
        name = None
        base = "RefCounted"
        for ln, ind, text, _ in lines:
            if ind == 0:
                m = re.match(r"class_name\s+(\w+)", text)
                if m:
                    name = m.group(1)
                m = re.match(r"extends\s+(\w+)", text)
                if m:
                    base = m.group(1)
        if name is None:
            for an, apath in autoloads.items():
                if apath == rel:
                    name = an
        info = ClassInfo(name or rel, rel, base)
        seen = {}
        for ln, ind, text, _ in lines:
            if ind != 0:
                continue
            fi = parse_func_header(text, ln)
            if fi:
                if fi.name in info.funcs:
                    err(rel, ln, "duplicate function " + fi.name)
                info.funcs[fi.name] = fi
                continue
            m = re.match(r"(?:@\w+(?:\([^)]*\))?\s+)*(?:static\s+)?var\s+(\w+)\s*(?::\s*([\w\[\]\.]+))?\s*(:=)?\s*(.*)$", text)
            if m:
                vname, vtype, infer, rhs = m.group(1), m.group(2), m.group(3), m.group(4)
                if vname in seen:
                    err(rel, ln, "duplicate member " + vname)
                seen[vname] = ln
                if vtype is None and infer:
                    mm = re.match(r"(\w+)\.new\(", rhs)
                    vtype = mm.group(1) if mm else None
                info.vars[vname] = vtype
                continue
            m = re.match(r"const\s+(\w+)", text)
            if m:
                info.consts[m.group(1)] = True
                continue
            m = re.match(r"signal\s+(\w+)\s*(?:\((.*)\))?\s*$", text)
            if m:
                info.signals[m.group(1)] = len(split_args(m.group(2) or ""))
                continue
            m = re.match(r"enum\s+(\w+)?\s*\{(.*)\}", text)
            if m:
                members = [x.split("=")[0].strip() for x in m.group(2).split(",") if x.strip()]
                if m.group(1):
                    info.enums[m.group(1)] = members
                info.enum_values.update(members)
        classes[info.name] = info
        by_path[rel] = info
    return classes, by_path


# ------------------------------------------------------------------ expression chain resolution

def member_of(cls, classes, name):
    """Looks a member up in a project class and its project base classes. Returns ('func'|'var'|'const'|'signal'|'enum', info) or None."""
    seen = 0
    c = cls
    while c is not None and seen < 8:
        if name in c.funcs:
            return "func", c.funcs[name]
        if name in c.vars:
            return "var", c.vars[name]
        if name in c.consts:
            return "const", None
        if name in c.signals:
            return "signal", c.signals[name]
        if name in c.enums:
            return "enum", None
        if name in c.enum_values:
            return "const", None
        c = classes.get(c.base)
        seen += 1
    if name in OBJ_MEMBERS:
        return "builtin", None
    base = cls.base
    if base in ("Node", "Node2D", "Control", "PanelContainer", "CanvasLayer", "SceneTree", "MainLoop") and (name in NODE_MEMBERS or name in SCENETREE_MEMBERS):
        return "builtin", None
    return None


IDENT = re.compile(r"[A-Za-z_]\w*")


def scan_chains(text):
    """Finds member chains: yields (start_index, [segments]) with segments ('id', name) / ('call', argtext) / ('idx', None)."""
    i = 0
    n = len(text)
    out = []
    while i < n:
        m = IDENT.match(text, i)
        if not m or (i > 0 and (text[i - 1].isalnum() or text[i - 1] in "_.")):
            i += 1
            continue
        segs = [("id", m.group(0))]
        j = m.end()
        while j < n:
            if text[j] == "(":
                depth, k = 0, j
                while k < n:
                    if text[k] == "(":
                        depth += 1
                    elif text[k] == ")":
                        depth -= 1
                        if depth == 0:
                            break
                    k += 1
                segs.append(("call", text[j + 1:k]))
                j = k + 1
            elif text[j] == "[":
                depth, k = 0, j
                while k < n:
                    if text[k] == "[":
                        depth += 1
                    elif text[k] == "]":
                        depth -= 1
                        if depth == 0:
                            break
                    k += 1
                segs.append(("idx", None))
                j = k + 1
            elif text[j] == "." and j + 1 < n and (text[j + 1].isalpha() or text[j + 1] == "_"):
                mm = IDENT.match(text, j + 1)
                segs.append(("id", mm.group(0)))
                j = mm.end()
            else:
                break
        out.append((i, segs, j))
        i = max(j, m.end())
    return out


def type_of_name(name, env, cls):
    if name in env:
        return env[name]
    if name in cls.vars:
        return cls.vars[name]
    return None


def check_chain(segs, env, cls, classes, rel, ln, autoloads):
    """Walks one chain; reports member errors; returns the resulting project-class name or None."""
    first = segs[0][1]
    cur = None            # current project class name
    kind = None           # what the previous segment was
    static_ctx = False
    last_member = None
    idx = 1
    if first in classes and first not in env and first not in cls.vars:
        cur = first
        static_ctx = first not in autoloads
    elif first in env or first in cls.vars:
        cur = type_of_name(first, env, cls)
        kind = "var"
    elif first == "self":
        cur = cls.name
    elif first in cls.funcs:
        # bare call of an own function
        fi = cls.funcs[first]
        if idx < len(segs) and segs[idx][0] == "call":
            lo, hi = fi.arity()
            n = len(split_args(segs[idx][1]))
            if n < lo or n > hi:
                err(rel, ln, "%s() takes %d..%d arguments, called with %d" % (first, lo, hi, n))
            cur = fi.ret if fi.ret in classes else None
            idx += 1
        else:
            cur = None
    else:
        cur = None
    if cur is not None and cur not in classes:
        cur = None
    while idx < len(segs) and cur is not None:
        seg = segs[idx]
        if seg[0] == "idx":
            cur = None
            break
        if seg[0] == "call":
            # call on a previous var/func result: only meaningful for Callable vars; stop
            cur = None
            break
        name = seg[1]
        c = classes[cur]
        mem = member_of(c, classes, name)
        if mem is None:
            err(rel, ln, "%s has no member '%s'" % (cur, name))
            cur = None
            break
        mk, info = mem
        nxt = idx + 1
        if mk == "func":
            if nxt < len(segs) and segs[nxt][0] == "call":
                lo, hi = info.arity()
                n = len(split_args(segs[nxt][1]))
                if n < lo or n > hi:
                    err(rel, ln, "%s.%s() takes %d..%d arguments, called with %d" % (cur, name, lo, hi, n))
                if static_ctx and not info.static and name != "new":
                    err(rel, ln, "%s.%s() is not static" % (cur, name))
                cur = info.ret if info.ret in classes else None
                idx = nxt + 1
                static_ctx = False
                continue
            cur = None
            break
        if mk == "var":
            cur = info if info in classes else None
            static_ctx = False
            idx += 1
            continue
        if mk == "signal":
            # signal.emit(...) / connect(...)
            if nxt < len(segs) and segs[nxt][0] == "id" and segs[nxt][1] == "emit":
                if nxt + 1 < len(segs) and segs[nxt + 1][0] == "call":
                    n = len(split_args(segs[nxt + 1][1]))
                    if n != info:
                        err(rel, ln, "signal %s.%s takes %d arguments, emit() has %d" % (cur, name, info, n))
            cur = None
            break
        cur = None
        break
    return cur


def infer_type_of_expr(rhs, env, cls, classes, autoloads):
    chains = scan_chains(rhs)
    if not chains:
        return None
    start, segs, _end = chains[0]
    if start != 0:
        return None
    # only trust the type when the chain is the whole expression
    return check_chain(segs, env, cls, classes, "", 0, autoloads) if len(segs) > 0 else None


# ------------------------------------------------------------------ per-function analysis

def analyse_file(rel, lines, info, classes, autoloads, all_names):
    members = set(info.funcs) | set(info.vars) | set(info.consts) | set(info.signals) | set(info.enums) | info.enum_values
    # inherited project members
    c = classes.get(info.base)
    depth = 0
    while c is not None and depth < 6:
        members |= set(c.funcs) | set(c.vars) | set(c.consts) | set(c.signals) | set(c.enums) | c.enum_values
        c = classes.get(c.base)
        depth += 1
    i = 0
    n = len(lines)
    while i < n:
        ln, ind, text, raw = lines[i]
        fi = parse_func_header(text, ln) if ind == 0 else None
        if fi is None:
            if ind == 0:
                check_toplevel_line(rel, ln, text, info)
            i += 1
            continue
        j = i + 1
        body = []
        while j < n and lines[j][1] > 0:
            body.append(lines[j])
            j += 1
        analyse_function(rel, fi, body, info, classes, autoloads, members)
        i = j


def check_toplevel_line(rel, ln, text, info):
    if re.match(r"(extends|class_name|const|var|signal|enum|static\s+func|static\s+var|func|@)", text):
        return
    err(rel, ln, "unexpected top-level statement: " + text[:60])


HEADER_RE = re.compile(r"^(if|elif|else|while|for|match)\b")


def analyse_function(rel, fi, body, info, classes, autoloads, members):
    env = {}                       # local name -> project class name or None
    for pname, ptype, _ in fi.params:
        env[pname] = ptype if ptype in classes else None
    scopes = [{"indent": 4, "names": set(p[0] for p in fi.params), "for": None}]
    declared_anywhere = set(p[0] for p in fi.params)
    # pass 1: scopes, redeclarations
    for ln, ind, text, raw in body:
        if ind % 4 != 0:
            err(rel, ln, "indent %d is not a multiple of 4" % ind)
        while len(scopes) > 1 and scopes[-1]["indent"] > ind:
            scopes.pop()
        if ind > scopes[-1]["indent"]:
            err(rel, ln, "unexpected indent (no block header above)")
        m = re.match(r"var\s+(\w+)", text)
        if m:
            name = m.group(1)
            for sc in scopes:
                if name in sc["names"]:
                    err(rel, ln, "variable '%s' is already declared in this or an enclosing scope (Godot parse error)" % name)
                    break
            scopes[-1]["names"].add(name)
            declared_anywhere.add(name)
        fm = re.match(r"for\s+(\w+)\s+in\s", text)
        if fm and text.rstrip().endswith(":"):
            vname = fm.group(1)
            for sc in scopes:
                if vname in sc["names"]:
                    warn(rel, ln, "loop variable '%s' shadows an enclosing variable" % vname)
                    break
            declared_anywhere.add(vname)
            scopes.append({"indent": ind + 4, "names": {vname}, "for": vname})
        elif text.rstrip().endswith(":") and not text.startswith(("var ", "const ")):
            scopes.append({"indent": ind + 4, "names": set(), "for": None})
        for lm in re.finditer(r"func\s*\(([^)]*)\)\s*:", text):
            for a in split_args(lm.group(1)):
                declared_anywhere.add(a.split(":")[0].strip())
    # pass 2: typing, member checks, undeclared names, := inference
    env_types = dict(env)
    for ln, ind, text, raw in body:
        vm = re.match(r"var\s+(\w+)\s*(?::\s*([\w\[\]\.]+))?\s*(:=)?\s*(.*)$", text)
        stmt = text
        if vm:
            vname, vtype, infer, rhs = vm.group(1), vm.group(2), vm.group(3), vm.group(4)
            if vtype is not None:
                env_types[vname] = vtype if vtype in classes else None
            elif infer:
                t = None
                rm = re.match(r"(\w+)\.new\(", rhs)
                if rm and rm.group(1) in classes:
                    t = rm.group(1)
                else:
                    t = infer_type_of_expr(rhs, env_types, info, classes, autoloads)
                env_types[vname] = t
                check_infer(rel, ln, vname, rhs, classes, info, env_types)
            else:
                env_types[vname] = None
            stmt = rhs if (infer or "=" in text) else ""
            if "=" in text and not infer:
                stmt = text.split("=", 1)[1]
        fm = re.match(r"for\s+(\w+)\s+in\s+(.*):\s*$", text)
        if fm:
            env_types[fm.group(1)] = None
            stmt = fm.group(2)
        for start, segs, _end in scan_chains(stmt):
            name0 = segs[0][1]
            check_chain(segs, env_types, info, classes, rel, ln, autoloads)
            check_name(rel, ln, name0, segs, declared_anywhere, members, classes, autoloads, info)
            check_connect(rel, ln, segs, info, declared_anywhere)


def check_name(rel, ln, name, segs, declared, members, classes, autoloads, info):
    if name in KEYWORDS or name in declared or name in members or name in classes or name in autoloads:
        return
    if name in BUILTIN_LOWER or name in ENGINE_UPPER:
        return
    if name.startswith(("TYPE_", "MOUSE_", "HORIZONTAL_", "VERTICAL_", "KEY_", "NOTIFICATION_", "PRESET_", "ALIGNMENT_", "GROW_", "AUTOWRAP_", "FILE")):
        return
    if name.isupper():
        warn(rel, ln, "unknown constant-like name '%s'" % name)
        return
    if name in NODE_MEMBERS or name in SCENETREE_MEMBERS or name in OBJ_MEMBERS:
        return
    if name[0].isupper():
        warn(rel, ln, "unknown class/constant '%s'" % name)
        return
    err(rel, ln, "identifier '%s' is not declared" % name)


def check_connect(rel, ln, segs, info, declared):
    for k, seg in enumerate(segs):
        if seg[0] == "id" and seg[1] == "connect" and k + 1 < len(segs) and segs[k + 1][0] == "call":
            args = split_args(segs[k + 1][1])
            if args and re.fullmatch(r"\w+", args[0]) and args[0] not in declared:
                if args[0] not in info.funcs and args[0] not in info.vars:
                    err(rel, ln, "connect() handler '%s' does not exist" % args[0])


SAFE_INFER_HEAD = re.compile(r"^(int|str|float|bool|Vector2i?|Rect2i?|Color|PackedStringArray|PackedVector2Array|Callable|maxi|mini|maxf|minf|clampi|clampf|absi|absf|roundi|floori|ceili|round|ceil|floor|sqrt|cos|sin|lerp|abs|snappedf|len|randi|randf|min|max|clamp)\(")


def check_infer(rel, ln, vname, rhs, classes, info, env):
    """':=' needs a statically typed right side. Flags the common Variant sources (Dictionary.get, subscripts, ...)."""
    r = rhs.strip()
    if re.match(r"^[-+]?\d", r) or r.startswith(('"', "'")) or r in ("true", "false") or r.startswith(("[", "{", "not ", "!")):
        return
    chains = scan_chains(r)
    if not chains or chains[0][0] != 0 or chains[0][2] != len(r):
        return                                   # an operator expression: arithmetic/comparison results are typed
    segs = chains[0][1]
    last = segs[-1]
    VARIANT_CALLS = {"get", "pop_back", "pop_front", "pop_at", "front", "back", "duplicate", "parse_string", "pick_random", "get_value", "get_meta", "get_node_or_null"}
    if last[0] == "idx":
        warn(rel, ln, "':=' on a subscript (Variant) for '%s': %s" % (vname, r[:70]))
    elif last[0] == "call" and len(segs) >= 2 and segs[-2][0] == "id" and segs[-2][1] in VARIANT_CALLS:
        warn(rel, ln, "':=' on .%s() (Variant) for '%s': %s" % (segs[-2][1], vname, r[:70]))
    elif last[0] == "call" and segs[0][1] in classes and len(segs) >= 3 and segs[1][0] == "id":
        fi = classes[segs[0][1]].funcs.get(segs[1][1])
        if fi is not None and fi.ret is None:
            warn(rel, ln, "':=' from a function without a declared return type: %s" % r[:70])


# ------------------------------------------------------------------ project-level checks

def check_project_files(files, autoloads):
    proj = (ROOT / "project.godot").read_text(encoding="utf-8")
    for name, path in autoloads.items():
        if not (ROOT / path).exists():
            err("project.godot", 0, "autoload %s points to a missing file %s" % (name, path))
    m = re.search(r'run/main_scene="res://([^"]+)"', proj)
    if m and not (ROOT / m.group(1)).exists():
        err("project.godot", 0, "main scene missing: " + m.group(1))
    for p in ROOT.rglob("*.tscn"):
        for mm in re.finditer(r'path="res://([^"]+)"', p.read_text(encoding="utf-8")):
            if not (ROOT / mm.group(1)).exists():
                err(p.relative_to(ROOT).as_posix(), 0, "missing resource " + mm.group(1))
    for rel in files:
        text = (ROOT / rel).read_text(encoding="utf-8")
        for ln, line in enumerate(text.split("\n"), 1):
            for mm in re.finditer(r'(?:preload|load)\("res://([^"]+)"\)', line):
                if not (ROOT / mm.group(1)).exists():
                    err(rel, ln, "load() of a missing file: " + mm.group(1))


def read_autoloads():
    out = {}
    proj = (ROOT / "project.godot").read_text(encoding="utf-8")
    sec = False
    for line in proj.split("\n"):
        if line.strip().startswith("["):
            sec = line.strip() == "[autoload]"
            continue
        if sec and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip().strip('"').lstrip("*").replace("res://", "")
    return out


def check_json():
    data = {}
    for p in sorted((ROOT / "data").rglob("*.json")):
        rel = p.relative_to(ROOT).as_posix()
        try:
            data[p.name] = json.loads(p.read_text(encoding="utf-8"))
        except Exception as exc:  # noqa
            err(rel, 0, "invalid JSON: %s" % exc)
    g = lambda name, key: data.get(name, {}).get(key, {})
    weapons, items, skills = g("weapons.json", "weapons"), g("items.json", "items"), g("skills.json", "skills")
    classes, chars, sigils = g("classes.json", "classes"), g("characters.json", "characters"), g("sigils.json", "sigils")
    terrain = g("terrain.json", "terrain")
    stat_keys = {"hp", "mp", "str", "dex", "int", "vit", "spd", "lck", "acc", "eva", "ldr", "mor"}
    for k, it in items.items():
        if it.get("slot") == "weapon" and it.get("weapon_id") not in weapons:
            err("data/items.json", 0, "%s: unknown weapon_id %s" % (k, it.get("weapon_id")))
        for s in it.get("bonus", {}):
            if s not in stat_keys:
                err("data/items.json", 0, "%s: unknown bonus stat %s" % (k, s))
        n = it.get("sockets", 0)
        for a, b in it.get("links", []):
            if a >= n or b >= n:
                err("data/items.json", 0, "%s: link out of range" % k)
        if it.get("bound_to") and it["bound_to"] not in chars:
            err("data/items.json", 0, "%s: bound_to unknown character" % k)
    for k, sd in sigils.items():
        if len(sd.get("levels", [])) != len(sd.get("ap", [])) + 1:
            err("data/sigils.json", 0, "%s: levels must be ap thresholds + 1" % k)
        for lv in sd.get("levels", []):
            for sid in lv.get("skills", []):
                if sid not in skills:
                    err("data/sigils.json", 0, "%s: unknown skill %s" % (k, sid))
    for k, c in classes.items():
        for t in c.get("promotes_to", []):
            if not isinstance(t, str):
                err("data/classes.json", 0, "%s: bad promotion entry" % k)
    for k, ch in chars.items():
        if ch.get("class_id") not in classes:
            err("data/characters.json", 0, "%s: unknown class %s" % (k, ch.get("class_id")))
        if ch.get("weapon_id") not in weapons:
            err("data/characters.json", 0, "%s: unknown weapon %s" % (k, ch.get("weapon_id")))
        for slot, iid in ch.get("equipment", {}).items():
            if iid and iid not in items:
                err("data/characters.json", 0, "%s: unknown item %s" % (k, iid))
        for grp, arr in ch.get("sigils", {}).items():
            for sid in arr:
                if sid and (sid if isinstance(sid, str) else sid.get("id")) not in sigils:
                    err("data/characters.json", 0, "%s: unknown sigil %s" % (k, sid))
        for sid in ch.get("skills", []):
            if sid not in skills:
                err("data/characters.json", 0, "%s: unknown skill %s" % (k, sid))
    start = data.get("campaign_start.json", {})
    for cid in start.get("party", []):
        if cid not in chars:
            err("data/campaign_start.json", 0, "unknown party member " + cid)
    for iid in start.get("inventory", {}):
        if iid not in items:
            err("data/campaign_start.json", 0, "unknown inventory item " + iid)
    for sid in start.get("sigils", []):
        if (sid if isinstance(sid, str) else sid.get("id")) not in sigils:
            err("data/campaign_start.json", 0, "unknown sigil " + str(sid))
    enc = data.get("encounters.json", {})
    for grp in enc.get("skirmish", {}).get("groups", []):
        for cid in grp.get("units", []):
            if cid not in chars:
                err("data/encounters.json", 0, "unknown enemy " + cid)
    for fname, d in data.items():
        if "terrain" in d and isinstance(d.get("terrain"), list):
            legend = d.get("legend", {})
            for ch in "".join(d["terrain"]):
                if ch not in legend:
                    err("data/battles/" + fname, 0, "terrain character %r has no legend entry" % ch)
            for tid in legend.values():
                if tid not in terrain:
                    err("data/battles/" + fname, 0, "legend terrain %s unknown" % tid)
            for u in d.get("units", []):
                if u.get("character_id") not in chars:
                    err("data/battles/" + fname, 0, "unknown unit " + str(u.get("character_id")))
    shop = data.get("shop.json")
    if shop:
        for sec, ids in (("items", items), ("sigils", sigils)):
            for iid in shop.get(sec, []):
                if iid not in ids:
                    err("data/shop.json", 0, "unknown %s id %s" % (sec, iid))
    return data


def main():
    autoloads = read_autoloads()
    files = load_files()
    classes, by_path = build_classes(files, autoloads)
    all_names = set(classes)
    for rel, lines in files.items():
        info = by_path[rel]
        analyse_file(rel, lines, info, classes, autoloads, all_names)
    check_project_files(files, autoloads)
    check_json()
    for w in warnings:
        print(w)
    for e in errors:
        print(e)
    print("")
    print("files: %d   classes: %d   errors: %d   warnings: %d" % (len(files), len(classes), len(errors), len(warnings)))
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
