// Electra One widget emulator — Fengari + canvas stubs
// Phase 1: render paint callbacks + touch events.

const RAW_BASE = "https://raw.githubusercontent.com/roomi-fields/electraone-widgets/main";

const CONST = {
  WIDTH: 2, HEIGHT: 3,
  LEFT: 0, RIGHT: 1, CENTER: 2,
  DOWN: 1, MOVE: 2, UP: 3, CLICK: 4, LONG_HOLD: 5, HOLD: 6,
  PT_CC7: 1, PT_VIRTUAL: 2, PT_NRPN: 3, PT_RPN: 4,
  PORT_1: 1, PORT_2: 2, PORT_CTRL: 3,
  MODEL_MK2: "mk2",
  RED: 0xFF0000, GREEN: 0x00FF00, BLUE: 0x0000FF, YELLOW: 0xFFFF00,
  PURPLE: 0xB14AE0, ORANGE: 0xFF8A1F, WHITE: 0xFFFFFF, BLACK: 0x000000,
};
const STAGE_W = 1016, STAGE_H = 560;

function logMsg(s, cls = "") {
  const log = document.getElementById("log");
  const line = document.createElement("div");
  if (cls) line.className = cls;
  line.textContent = s;
  log.appendChild(line);
  log.scrollTop = log.scrollHeight;
}

class Stage {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.controls = {};
    this.paintCbs = {};
    this.touchCbs = {};
    this.potCbs = {};
    this.currentColor = 0xFFFFFF;
  }
  hexColor(c) { return "#" + ("000000" + (c >>> 0).toString(16)).slice(-6); }
  paintAll() {
    this.ctx.fillStyle = "#000";
    this.ctx.fillRect(0, 0, STAGE_W, STAGE_H);
    for (const id of Object.keys(this.paintCbs)) this.paintOne(id);
  }
  paintOne(id) {
    const ctrl = this.controls[id];
    const cb = this.paintCbs[id];
    if (!ctrl || !cb) return;
    const [x, y, w, h] = ctrl.bounds;
    this.ctx.save();
    this.ctx.translate(x, y);
    this.ctx.beginPath();
    this.ctx.rect(0, 0, w, h);
    this.ctx.clip();
    try { cb(ctrl); } catch (e) { logMsg("paint err: " + e.message, "err"); }
    this.ctx.restore();
  }
}

class Control {
  constructor(id, stage, bounds) {
    this.id = id;
    this.stage = stage;
    this.bounds = bounds.slice();
    this.value = 0;
  }
  getBounds() {
    const [x, y, w, h] = this.bounds;
    return { 0: x, 1: y, 2: w, 3: h, x, y, width: w, height: h };
  }
  setBounds(b) {
    // accept Lua-array {1:x,2:y,3:w,4:h} or JS-array {0:x,1:y,2:w,3:h} or object
    const x = b[0] ?? b[1] ?? b.x ?? this.bounds[0];
    const y = b[1] ?? b[2] ?? b.y ?? this.bounds[1];
    const w = b[2] ?? b[3] ?? b.width ?? this.bounds[2];
    const h = b[3] ?? b[4] ?? b.height ?? this.bounds[3];
    this.bounds = [x, y, w, h];
  }
  setPaintCallback(fn) { this.stage.paintCbs[this.id] = fn; }
  setTouchCallback(fn) { this.stage.touchCbs[this.id] = fn; }
  setPotCallback(fn)   { this.stage.potCbs[this.id]   = fn; }
  setValue(v) { this.value = v; }
  getValue() { return { getDefault: () => 0 }; }
  setColor() {}
  setLabel() {}
  setName() {}
  setVisible() {}
  setSlot() {}
  getId() { return this.id; }
  repaint() { this.stage.paintOne(this.id); }
}

// ============ Fengari helpers ============

let F, lua, lauxlib, lualib, to_luastring, to_jsstring;

function initFengari() {
  if (!window.fengari) throw new Error("Fengari not loaded (check network / CDN)");
  F = window.fengari;
  lua = F.lua; lauxlib = F.lauxlib; lualib = F.lualib;
  to_luastring = F.to_luastring; to_jsstring = F.to_jsstring;
}

function pushValue(L, v) {
  if (v === null || v === undefined) lua.lua_pushnil(L);
  else if (typeof v === "number") lua.lua_pushnumber(L, v);
  else if (typeof v === "string") lua.lua_pushstring(L, to_luastring(v));
  else if (typeof v === "boolean") lua.lua_pushboolean(L, v ? 1 : 0);
  else if (typeof v === "function") lua.lua_pushjsfunction(L, wrapFn(v));
  else if (typeof v === "object") pushObject(L, v);
  else lua.lua_pushnil(L);
}

function wrapFn(fn) {
  return function (L) {
    const n = lua.lua_gettop(L);
    const args = [];
    for (let i = 1; i <= n; i++) args.push(luaToJS(L, i));
    let ret;
    try { ret = fn.apply(null, args); }
    catch (e) { logMsg("stub err: " + e.message, "err"); return 0; }
    if (ret === undefined || ret === null) return 0;
    pushValue(L, ret);
    return 1;
  };
}

function pushObject(L, obj) {
  // Plain map/module as Lua table
  lua.lua_createtable(L, 0, Object.keys(obj).length);
  for (const [k, v] of Object.entries(obj)) {
    pushValue(L, v);
    lua.lua_setfield(L, -2, to_luastring(k));
  }
}

// Wrap a JS object with methods as Lua userdata (colon-call semantics)
function pushJSAsLua(L, obj) {
  lua.lua_createtable(L, 0, 0);
  const tableIdx = lua.lua_gettop(L);
  lua.lua_createtable(L, 0, 1);
  lua.lua_pushjsfunction(L, (L) => {
    const key = to_jsstring(lua.lua_tostring(L, 2));
    const v = obj[key];
    if (typeof v === "function") {
      lua.lua_pushjsfunction(L, (L) => {
        const n = lua.lua_gettop(L);
        const args = [];
        for (let i = 2; i <= n; i++) args.push(luaToJS(L, i));  // skip self
        let ret;
        try { ret = v.apply(obj, args); }
        catch (e) { logMsg(`method err ${key}: ${e.message}`, "err"); return 0; }
        if (ret === undefined || ret === null) return 0;
        pushValue(L, ret);
        return 1;
      });
      return 1;
    }
    if (v !== undefined) { pushValue(L, v); return 1; }
    lua.lua_pushnil(L);
    return 1;
  });
  lua.lua_setfield(L, -2, to_luastring("__index"));
  lua.lua_setmetatable(L, tableIdx);
}

function luaToJS(L, i) {
  const t = lua.lua_type(L, i);
  if (t === lua.LUA_TSTRING)   return to_jsstring(lua.lua_tostring(L, i));
  if (t === lua.LUA_TNUMBER)   return lua.lua_tonumber(L, i);
  if (t === lua.LUA_TBOOLEAN)  return Boolean(lua.lua_toboolean(L, i));
  if (t === lua.LUA_TNIL)      return null;
  if (t === lua.LUA_TFUNCTION) {
    const ref = lauxlib.luaL_ref(L, lua.LUA_REGISTRYINDEX);
    return function (...args) {
      lua.lua_rawgeti(L, lua.LUA_REGISTRYINDEX, ref);
      for (const a of args) pushValue(L, a);
      if (lua.lua_pcall(L, args.length, 0, 0) !== 0) {
        logMsg("cb err: " + to_jsstring(lua.lua_tostring(L, -1)), "err");
        lua.lua_pop(L, 1);
      }
    };
  }
  if (t === lua.LUA_TTABLE) {
    const obj = {};
    lua.lua_pushnil(L);
    const abs = lua.lua_absindex(L, i);
    while (lua.lua_next(L, abs) !== 0) {
      const k = luaToJS(L, -2);
      const v = luaToJS(L, -1);
      obj[k] = v;
      lua.lua_pop(L, 1);
    }
    return obj;
  }
  // userdata / other
  return null;
}

// ============ Environment ============

function setupEnv(L, stage) {
  // constants
  for (const [k, v] of Object.entries(CONST)) {
    if (typeof v === "number") lua.lua_pushnumber(L, v);
    else lua.lua_pushstring(L, to_luastring(v));
    lua.lua_setglobal(L, to_luastring(k));
  }

  // graphics
  pushObject(L, {
    setColor: (c) => { stage.currentColor = c; const col = stage.hexColor(c); stage.ctx.fillStyle = col; stage.ctx.strokeStyle = col; },
    fillRect: (x, y, w, h) => stage.ctx.fillRect(x, y, w, h),
    drawRect: (x, y, w, h) => stage.ctx.strokeRect(x, y, w, h),
    fillCircle: (cx, cy, r) => { stage.ctx.beginPath(); stage.ctx.arc(cx, cy, r, 0, Math.PI * 2); stage.ctx.fill(); },
    drawCircle: (cx, cy, r) => { stage.ctx.beginPath(); stage.ctx.arc(cx, cy, r, 0, Math.PI * 2); stage.ctx.stroke(); },
    drawLine: (x1, y1, x2, y2) => { stage.ctx.beginPath(); stage.ctx.moveTo(x1, y1); stage.ctx.lineTo(x2, y2); stage.ctx.stroke(); },
    print: (x, y, text, size) => {
      stage.ctx.font = `${size || 10}px 'Open Sans', sans-serif`;
      stage.ctx.textBaseline = "top";
      stage.ctx.fillText(String(text ?? ""), x, y);
    },
    setPixel: (x, y) => stage.ctx.fillRect(x, y, 1, 1),
    drawPixel: (x, y) => stage.ctx.fillRect(x, y, 1, 1),
  });
  lua.lua_setglobal(L, to_luastring("graphics"));

  // controls
  const controls = {
    get: (id) => {
      if (!stage.controls[id]) stage.controls[id] = new Control(id, stage, [0, 0, STAGE_W, STAGE_H]);
      return stage.controls[id];
    },
  };
  lua.lua_createtable(L, 0, 1);
  lua.lua_pushjsfunction(L, (L) => {
    const id = lua.lua_tonumber(L, 1);
    pushJSAsLua(L, controls.get(id));
    return 1;
  });
  lua.lua_setfield(L, -2, to_luastring("get"));
  lua.lua_setglobal(L, to_luastring("controls"));

  // devices
  const fakeDevice = { getPort: () => CONST.PORT_1, getChannel: () => 1, getId: () => 1 };
  lua.lua_createtable(L, 0, 1);
  lua.lua_pushjsfunction(L, (L) => { pushJSAsLua(L, fakeDevice); return 1; });
  lua.lua_setfield(L, -2, to_luastring("get"));
  lua.lua_setglobal(L, to_luastring("devices"));

  // parameterMap, midi, timer — stubs
  pushObject(L, { get: () => 0, set: () => {}, send: () => {} });
  lua.lua_setglobal(L, to_luastring("parameterMap"));
  pushObject(L, {
    sendControlChange: () => {}, sendNoteOn: () => {}, sendNoteOff: () => {},
    sendSysex: () => {}, sendProgramChange: () => {}, sendPitchBend: () => {},
    sendControlChange14Bit: () => {}, sendNrpn: () => {}, sendRpn: () => {},
    sendAfterTouchChannel: () => {}, sendAfterTouchPoly: () => {},
    sendClock: () => {}, sendStart: () => {}, sendStop: () => {},
  });
  lua.lua_setglobal(L, to_luastring("midi"));
  pushObject(L, { enable: () => {}, disable: () => {}, setPeriod: () => {}, setBpm: () => {} });
  lua.lua_setglobal(L, to_luastring("timer"));

  // preset table
  lua.lua_createtable(L, 0, 0);
  lua.lua_setglobal(L, to_luastring("preset"));

  // window (Ephemera-style) - re-paints the whole stage
  pushObject(L, { addAndMakeVisible: () => {}, repaint: () => stage.paintAll() });
  lua.lua_setglobal(L, to_luastring("window"));

  // Component constructor (Ephemera)
  lua.lua_pushjsfunction(L, (L) => {
    const id = lua.lua_tonumber(L, 1);
    // args: id, color, label, bounds{x,y,width,height}
    const bt = luaToJS(L, 4) || { x: 0, y: 0, width: 100, height: 100 };
    const ctrl = new Control(id, stage, [bt.x || 0, bt.y || 0, bt.width || 100, bt.height || 100]);
    stage.controls[id] = ctrl;
    pushJSAsLua(L, ctrl);
    return 1;
  });
  lua.lua_setglobal(L, to_luastring("Component"));

  // controller.isRequired
  lua.lua_createtable(L, 0, 1);
  lua.lua_pushjsfunction(L, (L) => { lua.lua_pushboolean(L, 1); return 1; });
  lua.lua_setfield(L, -2, to_luastring("isRequired"));
  lua.lua_setglobal(L, to_luastring("controller"));

  // info
  pushObject(L, { setText: () => {} });
  lua.lua_setglobal(L, to_luastring("info"));

  // print → log
  lua.lua_pushjsfunction(L, (L) => {
    const n = lua.lua_gettop(L);
    const parts = [];
    for (let i = 1; i <= n; i++) parts.push(luaToJS(L, i));
    logMsg("[lua] " + parts.join("\t"), "info");
    return 0;
  });
  lua.lua_setglobal(L, to_luastring("print"));
}

async function runLua(L, code) {
  const buf = to_luastring(code);
  if (lauxlib.luaL_loadbuffer(L, buf, buf.length, to_luastring("=widget")) !== 0) {
    logMsg("load err: " + to_jsstring(lua.lua_tostring(L, -1)), "err");
    lua.lua_pop(L, 1);
    return;
  }
  if (lua.lua_pcall(L, 0, 0, 0) !== 0) {
    logMsg("run err: " + to_jsstring(lua.lua_tostring(L, -1)), "err");
    lua.lua_pop(L, 1);
    return;
  }
  // Call preset.onLoad
  lua.lua_getglobal(L, to_luastring("preset"));
  lua.lua_getfield(L, -1, to_luastring("onLoad"));
  if (lua.lua_isfunction(L, -1)) {
    if (lua.lua_pcall(L, 0, 0, 0) !== 0) {
      logMsg("onLoad err: " + to_jsstring(lua.lua_tostring(L, -1)), "err");
      lua.lua_pop(L, 1);
    }
  } else {
    lua.lua_pop(L, 1);
  }
  lua.lua_pop(L, 1);
}

async function loadWidget(slug) {
  document.getElementById("log").innerHTML = "";
  logMsg(`Loading widget: ${slug}`, "info");
  document.getElementById("status").textContent = "…";

  const canvas = document.getElementById("canvas");
  const stage = new Stage(canvas);

  // Pre-seed a few common control refs full-screen
  for (const id of [1, 4, 5]) stage.controls[id] = new Control(id, stage, [0, 0, STAGE_W, STAGE_H]);

  let code;
  try {
    code = await (await fetch(`${RAW_BASE}/widgets/${slug}/widget.lua`)).text();
  } catch (e) {
    logMsg("fetch lua err: " + e.message, "err");
    return;
  }
  // Strip attribution header comments (purely cosmetic)
  // (Lua handles -- comments natively, no need to strip)

  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);
  setupEnv(L, stage);
  await runLua(L, code);
  stage.paintAll();

  // Pointer → touch
  const toStage = (ev) => {
    const r = canvas.getBoundingClientRect();
    const sx = STAGE_W / r.width, sy = STAGE_H / r.height;
    return {
      x: Math.max(0, Math.min(STAGE_W, (ev.clientX - r.left) * sx)),
      y: Math.max(0, Math.min(STAGE_H, (ev.clientY - r.top) * sy)),
    };
  };
  const dispatch = (type, pt) => {
    for (const [id, cb] of Object.entries(stage.touchCbs)) {
      const ctrl = stage.controls[id];
      if (!ctrl) continue;
      const [x, y, w, h] = ctrl.bounds;
      if (pt.x >= x && pt.x < x + w && pt.y >= y && pt.y < y + h) {
        try { cb(ctrl, { type, x: pt.x - x, y: pt.y - y }); }
        catch (e) { logMsg("touch err: " + e.message, "err"); }
      }
    }
  };
  let dragging = false;
  canvas.addEventListener("pointerdown", (ev) => { ev.preventDefault(); dragging = true; dispatch(CONST.DOWN, toStage(ev)); });
  canvas.addEventListener("pointermove", (ev) => { if (dragging) dispatch(CONST.MOVE, toStage(ev)); });
  canvas.addEventListener("pointerup",   (ev) => { dragging = false; dispatch(CONST.UP, toStage(ev)); });
  canvas.addEventListener("pointerleave",(ev) => { if (dragging) { dragging = false; dispatch(CONST.UP, toStage(ev)); } });

  document.getElementById("status").textContent = "✓ running";
}

async function boot() {
  try { initFengari(); }
  catch (e) { logMsg(e.message, "err"); return; }
  logMsg("Fengari loaded.", "info");

  // populate widgets
  let ws = [];
  try {
    ws = await (await fetch("../widgets.json")).json();
  } catch (e) {
    logMsg("widgets.json fetch err: " + e.message, "err");
  }
  const sel = document.getElementById("widget-select");
  sel.innerHTML = "";
  ws.forEach(w => {
    const o = document.createElement("option");
    o.value = w.slug;
    o.textContent = w.name;
    sel.appendChild(o);
  });
  const params = new URLSearchParams(location.search);
  if (params.get("w")) sel.value = params.get("w");
  sel.addEventListener("change", () => { location.search = "?w=" + sel.value; });
  document.getElementById("reload").addEventListener("click", () => location.reload());

  await loadWidget(sel.value || "xypad");
}

// Boot when both Fengari UMD and this file are ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}
